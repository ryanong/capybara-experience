# Capybara::Experience
We love Capybara! We think it's a great interface for testing Ruby web applications. But there are some pain points with the developer experience of using Capybara. We created this gem to address some of those pain points and added a few niceties along the way.

Problems with/unsolved by vanilla Capybara:
* Managing multiple user sessions in a single test, e.g. comparing customer-facing and admin experiences after interactions on either end.
* Managing shared behavior for component interactions irrespective of page or test context
* Provide semantically rich context to a collection of interactions & assertions, with clearer scope than comments 

Capybara::Experience has a few core concepts:
* Capabilities
* Experiences 
* Behaviors

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capybara-experience'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capybara-experience

## Usage

### Setup

#### RSpec
```ruby
# spec/spec_helper.rb
require "capybara/experience"
require "capybara/experience/rspec"
```

This automatically includes `Capybara::Experience::DSL` and `BehaviorDSL` in feature specs.

#### Minitest
```ruby
# test/test_helper.rb
require "capybara/experience"
require "capybara/experience/minitest"
```

Include the modules in your test class:
```ruby
class ApplicationIntegrationTest < Minitest::Test
  include Capybara::DSL
  include Capybara::Minitest::Assertions
  include Capybara::Experience::MinitestHooks # includes DSL and resets pool after each test
end
```

### Test Context & DSL

Experience instances accept a test context as their first argument, enabling assertions to be called from within Experience subclasses. When you subclass `Capybara::Experience`, a factory method is automatically added to `Capybara::Experience::DSL` that passes `self` as the test context:

```ruby
class UserExperience < Capybara::Experience
  # creates UserExperience() factory method on Capybara::Experience::DSL
end

# In a test:
ux = UserExperience() # equivalent to UserExperience.new(self)
```

### Basic Example

This scenario is for your standard user/admin.

1. Create a file for each experience:

```ruby
# spec/support/experiences/user_experience.rb
class UserExperience < Capybara::Experience
  include Rails.application.routes.url_helpers

  def login(user)
    @user = user
    login_as user, scope: :user
    visit '/'
    # assertions work inside Experience when test context is provided
    expect(page).to have_content("#{@user.name} Welcome!")
    self
  end

  private

  attr_reader :user
end
```

```ruby
# spec/support/experiences/admin_experience.rb
class AdminExperience < Capybara::Experience
  def login(user)
    @user = user
    login_as user, scope: :admin
    visit '/admin/login'
    expect(page).to have_content("Home")
  end

  private

  attr_reader :user
end
```

2. Create some capabilities. These capability files associate to each page, imagine each capability is an api to a page.

```ruby
# spec/support/capabilities/sign_up.rb
module Capabilities::SignUp
  def navigate_to_sign_up
    click_link "Sign Up"
  end

  def sign_up(email: , password: "password")
    fill_in "email", with: email
    fill_in "password", with: password
    fill_in "password_confirmation", with: password
    click_button "Submit"
    expect(page).to have_content("Welcome #{email}")
  end
end
```

3. Write the spec using the DSL factory methods:

```ruby
# spec/features/sign_up_flow_spec.rb
RSpec.describe "sign up flow", type: :feature do
  it "works" do
    behavior "user can sign up" do
      guest_ux = GuestExperience() # factory method passes self as test context
      guest_ux.navigate_to_sign_up

      guest_ux.sign_up(
        email: "user@example.com"
      )

      expect(guest_ux).to have_content "user@example.com"
      expect(guest_ux).to_not have_content "Login"
    end

    behavior "admin can see user" do
      admin_ux = AdminExperience()
      admin_ux.login
      expect(admin_ux).to have_content "user@example.com"
    end
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ryanong/capybara-experience.
