# frozen_string_literal: true

module Capybara
  class Experience
    module Session
      class << self
        def next(driver:)
          pool.next(driver)
        end

        def create(driver)
          ::Capybara::Session.new(driver, Capybara.app)
        end

        def pool
          @pool ||= Pool.new
        end
      end

      class Pool
        attr_accessor :idle, :taken

        def initialize
          @idle = []
          @taken = []
        end

        def next(driver)
          take_idle(driver) || create(driver)
        end

        def release
          taken.each(&:reset!)
          idle.concat(taken)
          taken.clear
        end

        private

        def take_idle(driver)
          idle.find { |s| s.mode == driver }.tap do |session|
            if session
              idle.delete(session)
              taken.push(session)
            end
          end
        end

        def create(driver)
          ::Capybara::Experience::Session.create(driver).tap do |session|
            taken.push(session)
          end
        end
      end
    end
  end
end
