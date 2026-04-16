require "spec_helper"
require "pry-byebug"

class RSpecUserExperience < Capybara::Experience
  def verify_content(text)
    visit "/foo"
    expect(page).to have_content(text)
  end
end

RSpec.feature Capybara::Experience do
  before do
    @page = nil
    Capybara.reset_sessions!
    Capybara::Experience::Pool.instance.reset_idle!
    Capybara::Experience::Pool.instance.clear
    Capybara::Experience::Pool.instance.idle.clear
  end

  it "delegates rspec assertions to test context" do
    ux = described_class.new(self)
    ux.visit "/foo"

    ux.expect(ux.page).to ux.have_content("Another World")
    ux.expect(ux.page).to ux.have_text("Another World")
    ux.expect(ux.page).not_to ux.have_content("Does not exist")
  end

  it "allows subclasses to use assertions" do
    klass = Class.new(described_class) do
      def verify_content(text)
        visit "/foo"
        expect(page).to have_content(text)
      end
    end

    ux = klass.new(self)
    ux.verify_content("Another World")
  end

  it "works without test context" do
    ux = described_class.new
    ux.visit "/foo"
    expect(ux).to have_content("Another World")
  end

  it "DSL creates factory method for subclass" do
    ux = RSpecUserExperience()
    expect(ux).to be_a(RSpecUserExperience)
    expect(ux.test_context).to eq(self)
  end

  it "DSL factory passes kwargs" do
    ux = RSpecUserExperience(driver_name: :javascript_test)
    expect(ux.driver_name).to eq(:javascript_test)
    expect(ux.test_context).to eq(self)
  end

  it "DSL factory method works with assertions" do
    ux = RSpecUserExperience()
    ux.verify_content("Another World")
  end

  it "test pool" do
    page.visit "/foo"
    expect(page).to have_content "Another World"

    ux = described_class.new
    ux.visit "/foo"
    expect(ux).to have_content "Another World"

    expect(Capybara::Experience::Pool.instance.size).to eq 2
    expect(Capybara::Experience::Pool.instance.idle.size).to eq 0

    behavior "resets session" do
      @page = nil
      Capybara.reset_sessions!
      Capybara::Experience::Pool.instance.reset_idle!

      expect(Capybara::Experience::Pool.instance.size).to eq 2
      expect(Capybara::Experience::Pool.instance.idle.size).to eq 2
    end

    behavior "reuse sessions" do
      ux = described_class.new
      ux.visit "/foo"
      expect(ux).to have_content "Another World"

      page.visit "/foo"
      expect(page).to have_content "Another World"

      expect(Capybara::Experience::Pool.instance.size).to eq 2
      expect(Capybara::Experience::Pool.instance.idle.size).to eq 0
    end

    behavior "use new drivers" do
      @page = nil
      Capybara.reset_sessions!
      Capybara::Experience::Pool.instance.reset_idle!
      Capybara.current_driver = Capybara.javascript_driver

      ux = described_class.new
      ux.visit "/foo"
      expect(ux).to have_content "Another World"

      page.visit "/foo"
      expect(page).to have_content "Another World"

      expect(Capybara::Experience::Pool.instance.size).to eq 4
      expect(Capybara::Experience::Pool.instance.idle.size).to eq 2
    end

    behavior "resets js sessions" do
      @page = nil
      Capybara.reset_sessions!
      Capybara::Experience::Pool.instance.reset_idle!

      expect(Capybara::Experience::Pool.instance.size).to eq 4
      expect(Capybara::Experience::Pool.instance.idle.size).to eq 4
    end

    behavior "reuse js sessions" do
      ux = described_class.new
      ux.visit "/foo"
      expect(ux).to have_content "Another World"

      page.visit "/foo"
      expect(page).to have_content "Another World"

      expect(Capybara::Experience::Pool.instance.size).to eq 4
      expect(Capybara::Experience::Pool.instance.idle.size).to eq 2
    end
  end
end
