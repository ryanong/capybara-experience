# frozen_string_literal: true
require "capybara/experience/session"

module Capybara
  class Experience
    include Capybara::DSL
    include Rails.application.routes.url_helpers
    include Warden::Test::Helpers

    delegate :t, to: I18n

    def initialize(driver_name: nil)
      @driver_name = driver_name
    end

    def reload_page
      visit current_url
    end

    def driver_name
      @driver_name ||= Capybara.current_driver
    end

    delegate :driver, to: :page

    def page
      @page ||= Experience::Session.next(driver: driver_name)
    end

    def self.wait_for_pending_requests
      Experience::Session.pool.taken.each do |session|
        session.server.try(:wait_for_pending_requests)
      end
    end

    def save_and_open_screenshot_full(path = nil, options = {})
      save_and_open_screenshot(path, options.merge(full: true))
    end

    def current_driver_adapter
      adapter = ShowMeTheCookies.adapters[driver_name]
      if adapter.nil?
        raise(ShowMeTheCookies::UnknownDriverError, "Unsupported driver #{driver_name}, use one of #{ShowMeTheCookies.adapters.keys} or register your new driver with ShowMeTheCookies.register_adapter")
      end
      adapter.new(page.driver)
    end

    def click_with_js(element)
      xpath = element.path
      execute_script <<~JS
      document.evaluate('#{xpath}', document, null, XPathResult.ANY_TYPE, null)
        .iterateNext()
        .click()
      JS
    end

    class Error < StandardError; end
  end
end
