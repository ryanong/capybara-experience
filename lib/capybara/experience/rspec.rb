# frozen_string_literal: true

module Capybara
  class Experience
    module BehaviorDSL
      def behavior(name)
        metadata[:description_args].push(name)
        refresh_description unless in_continuous_integration_env?
        yield
        metadata[:description_args].pop
        refresh_description unless in_continuous_integration_env?
      end

      private

      def refresh_description
        metadata[:description] = metadata[:description_args].join(" ")
        metadata[:full_description] = [metadata[:example_group][:full_description]].concat(metadata[:description_args]).join(" ")
      end

      def metadata
        RSpec.current_example.metadata
      end

      def in_continuous_integration_env?
        ENV["CI"].present?
      end
    end

    RSpec.configure do |config|
      config.include BehaviorDSL
    end
  end
end
