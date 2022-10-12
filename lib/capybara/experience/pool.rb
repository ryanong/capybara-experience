# frozen_string_literal: true
require "singleton"

module Capybara
  class Experience
    class Pool < Hash
      include Singleton

      def [](key)
        super(key) || begin
          driver, _session_name, app_object_id = key.split(":")
          take(driver: driver.to_sym, app_object_id: app_object_id.to_i, key: key)
        end
      end

      def take(driver: Capybara.current_driver, app_object_id: Capybara.app.object_id, key: nil)
        session = idle.find { |s| s.mode == driver && s.app.object_id == app_object_id }
        if session
          idle.delete(session)
          self[key] = delete(session_key(session)) if key
        else
          session = ::Capybara::Session.new(driver.to_sym, Capybara.app)
          key ||= session_key(session)
          self[key] = session
        end

        session
      end

      def idle
        @idle ||= []
      end

      def taken
        values - idle
      end

      def reset_idle!
        new_hash = each_with_object({}) do |(key, session), hash|
          hash[session_key(session)] = delete(key)
        end
        replace(new_hash)
        @idle = values

        nil
      end

      private

      def session_key(session)
        "#{session.mode}:#{session.object_id}:#{session.app.object_id}"
      end
    end
  end
end
