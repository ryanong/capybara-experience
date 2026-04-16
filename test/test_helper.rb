# frozen_string_literal: true
require "bundler/setup"
require "minitest/autorun"
require "capybara/minitest"
require "capybara/experience"
require "capybara/experience/minitest"
require "capybara/spec/test_app"

TestApp.set :host_authorization, { permitted_hosts: [] }
Capybara.app = TestApp
