# frozen_string_literal: true
require "capybara/dsl"
require "capybara/experience/pool"

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
      @page ||= Experience::Pool.instance.take(driver: driver_name)

      Capybara::Screenshot.final_session_name = @page.object_id if defined?(Capybara::Screenshot)

      @page
    end

    def self.wait_for_pending_requests
      Experience::Pool.taken.each do |session|
        session.server.try(:wait_for_pending_requests)
      end
    end

    class Error < StandardError; end

    module UnifySessionPool
      def page
        Capybara::Screenshot.final_session_name = Capybara.session_name if defined?(Capybara::Screenshot)

        super
      end

      private

      def session_pool
        @session_pool ||= Experience::Pool.instance
      end
    end
  end

  singleton_class.prepend Experience::UnifySessionPool
end
