# frozen_string_literal: true
require "capybara/minitest"

module Capybara
  class Experience
    module MinitestContext
      Capybara::Minitest::Assertions.instance_methods(false).each do |method_name|
        define_method(method_name) do |*args, **kwargs, &block|
          test_context.send(method_name, page, *args, **kwargs, &block)
        end
      end
    end

    module MinitestHooks
      def after_teardown
        Capybara::Experience::Pool.instance.reset_idle!
        super
      end
    end

    include MinitestContext
  end
end
