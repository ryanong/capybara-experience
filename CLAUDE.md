# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

capybara-experience is a Ruby gem that extends Capybara with session pooling, multi-user experience objects, and a behavior DSL for feature tests. It lets tests instantiate multiple `Capybara::Experience` objects that each get their own browser session from a shared pool, enabling tests that compare different user journeys side by side.

## Commands

- **Run all tests:** `bundle exec rake` or `bundle exec rspec`
- **Run a single test:** `bundle exec rspec spec/capybara/experience_spec.rb`
- **Install deps:** `bundle install`
- **Build gem:** `bundle exec rake build`
- **Release gem:** `bundle exec rake release`

## Architecture

Three core components, all under `Capybara::Experience`:

**`Experience`** (`lib/capybara/experience.rb`) — Includes `Capybara::DSL`. Each instance lazily acquires a session from the Pool via `page`. The `UnifySessionPool` module is prepended onto `Capybara`'s singleton class to route Capybara's global `session_pool` through `Experience::Pool`, unifying session management. Integrates with `capybara-screenshot` by setting `final_session_name`.

**`Pool`** (`lib/capybara/experience/pool.rb`) — Singleton that extends `Hash`. Manages session lifecycle: `take` returns an idle session matching the driver+app or creates a new one; `reset_idle!` marks all sessions as reusable. Sessions are keyed as `"driver:object_id:app_object_id"`. The `[]` override auto-creates sessions on cache miss, which is how Capybara's `session_pool` integration works.

**`BehaviorDSL`** (`lib/capybara/experience/rspec.rb`) — RSpec helper that provides `behavior` blocks for grouping steps within a single `it` block. Dynamically updates RSpec metadata so the test runner shows the current behavior name. Also registers an `after(:each)` hook on `type: :feature, js: true` tests to call `Pool#reset_idle!`.

## Test Setup

Tests use Capybara's built-in `TestApp` (Sinatra) as the rack app. A custom `:javascript_test` driver is registered as a RackTest driver to test driver-switching logic without requiring a real browser. The single feature spec covers pool allocation, session reuse across reset cycles, and driver switching.
