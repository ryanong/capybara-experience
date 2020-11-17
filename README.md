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

### Basic
This scenario is for your standard user/admin.
1. We need to create a file for each experience

```ruby
# spec/support/experiences/user_experience.rb
class UserExperience < Capybara::Experience
  def login(user)
    @user = user
    login_as user, scope: :user
    visit '/'
    assert_text "#{@user.name} Welcome!"
    self
  end

  private

  attr_reader :user
end
```

```ruby
# spec/support/experiences/user_experience.rb
class AdminExperience < Capybara::Experience
  def initialize(*args)
    super
  end

  def login(user)
    @user = user
    login_as user, scope: :admin
    visit '/admin/login'
    assert_text "Home"
  end

  private

  attr_reader :user
end
```

2. now we need to create some capabilities. These capability files associate to each page, imagine each capability is an api to a page.

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
    assert_text "Welcome #{email}"
  end
end
```

3. write the spec
```ruby
# spec/features/sign_up_flow_spec.rb
RSpec.describe "sign up flow", feature: true do
  let(:guest_experience) { GuestExperience.new.extend(Capabilities::SignUp) }
  let(:admin_experience) { AdminExperience.new.extend(Capabilities::Admin::ManageUser) }
  
  it "works" do
    behavior "user can sign up" do # behaviors are an added DSL by capybara-experiences to group interactions & assertions
      guest_ux = GuestExperience.new
      guest_ux.navigate_to_sign_up

      guest_ux.sign_up(
        email: "user@example.com"
      )

      expect(guest_ux).to have_content "user@example.com"
      expect(guest_ux).to_not have_content "Login"
    end

    behavior "admin can see user" do
      admin_ux = AdminExperience.new
      admin_ux.login
      admin_ux.to have_content "user@example.com"
    end
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ryanong/capybara-experience.
