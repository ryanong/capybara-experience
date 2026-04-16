# frozen_string_literal: true

require "capybara/experience"

if defined?(RSpec)
  require "capybara/experience/rspec"
elsif defined?(Minitest)
  require "capybara/experience/minitest"
end

module Capybara
  class Experience
    module ScreenshotOverride
      def page
        @_capybara_experience_page_override || super
      end

      private

      def take_failed_screenshot
        last_session = Experience::Pool.instance.last_session
        return super unless last_session

        @_capybara_experience_page_override = last_session
        super
      ensure
        @_capybara_experience_page_override = nil
      end
    end
  end
end

if defined?(ActiveSupport)
  ActiveSupport.on_load(:action_dispatch_system_test_case) do
    ActionDispatch::SystemTestCase.prepend(Capybara::Experience::ScreenshotOverride)
  end
end
