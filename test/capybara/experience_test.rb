# frozen_string_literal: true
require_relative "../test_helper"

class TestUserExperience < Capybara::Experience
  def verify_content(text)
    visit "/foo"
    assert_text(text)
  end
end

class ExperienceMinitestTest < Minitest::Test
  include Capybara::DSL
  include Capybara::Minitest::Assertions
  include Capybara::Experience::MinitestHooks

  def setup
    Capybara::Experience::Pool.instance.clear
    Capybara::Experience::Pool.instance.idle.clear
  end

  def teardown
    Capybara.reset_sessions!
  end

  def test_delegates_assert_text_to_test_context
    ux = Capybara::Experience.new(self)
    ux.visit "/foo"

    ux.assert_text("Another World")
  end

  def test_delegates_assert_no_text_to_test_context
    ux = Capybara::Experience.new(self)
    ux.visit "/foo"

    ux.assert_no_text("Does not exist")
  end

  def test_delegates_assert_selector_to_test_context
    ux = Capybara::Experience.new(self)
    ux.visit "/"

    ux.assert_selector(:link, "Relative")
  end

  def test_delegates_assert_no_selector_to_test_context
    ux = Capybara::Experience.new(self)
    ux.visit "/"

    ux.assert_no_selector(:link, "Nonexistent")
  end

  def test_subclass_can_use_assertions
    klass = Class.new(Capybara::Experience) do
      def verify_content(text)
        visit "/foo"
        assert_text(text)
      end
    end

    ux = klass.new(self)
    ux.verify_content("Another World")
  end

  def test_assertions_use_experience_page_not_test_page
    visit "/"
    ux = Capybara::Experience.new(self)
    ux.visit "/foo"

    # Test context page is at "/", Experience page is at "/foo"
    # Assertions on the Experience should use the Experience's page
    ux.assert_text("Another World")
    ux.assert_no_text("Hello world")
  end

  def test_works_without_test_context
    ux = Capybara::Experience.new
    ux.visit "/foo"

    assert_text(ux.page, "Another World")
  end

  def test_assertions_increment_test_context_counter
    ux = Capybara::Experience.new(self)
    ux.visit "/foo"

    count_before = self.assertions
    ux.assert_text("Another World")
    ux.assert_no_text("Does not exist")
    assert_equal count_before + 2, self.assertions
  end

  def test_dsl_creates_factory_method_for_subclass
    ux = TestUserExperience()
    assert_instance_of TestUserExperience, ux
    assert_equal self, ux.test_context
  end

  def test_dsl_factory_passes_kwargs
    ux = TestUserExperience(driver_name: :javascript_test)
    assert_equal :javascript_test, ux.driver_name
    assert_equal self, ux.test_context
  end

  def test_dsl_factory_method_works_with_assertions
    ux = TestUserExperience()
    ux.verify_content("Another World")
  end

  def test_behavior_yields_block
    executed = false
    behavior "step one" do
      executed = true
    end
    assert executed
  end

  def test_behavior_tracks_current_behavior
    behavior "login" do
      assert_equal "login", current_behavior
    end
    assert_equal "", current_behavior
  end

  def test_behavior_nests
    behavior "login" do
      behavior "fill in form" do
        assert_equal "login fill in form", current_behavior
      end
      assert_equal "login", current_behavior
    end
    assert_equal "", current_behavior
  end

  def test_behavior_pops_on_failure
    assert_raises(RuntimeError) do
      behavior "broken step" do
        raise "boom"
      end
    end
    assert_equal "", current_behavior
  end

  def test_pool_resets_via_minitest_hooks
    ux = Capybara::Experience.new(self)
    ux.visit "/foo"

    assert_equal 1, Capybara::Experience::Pool.instance.taken.size
  end
end
