require "spec_helper"
require "pry-byebug"

RSpec.feature Capybara::Experience do
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
