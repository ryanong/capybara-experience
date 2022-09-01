# frozen_string_literal: true
require "capybara/dsl"
require "capybara/experience/session"

module Capybara
  class Experience
    include Capybara::DSL

    delegate :t, to: I18n if defined?(I18n)

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
