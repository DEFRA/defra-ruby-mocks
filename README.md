# Defra Ruby Mocks

A Rails Engine used by the [Ruby services team](https://github.com/DEFRA/ruby-services-team) in their digital services.

We use it to mock external services such as Companies House, so we can performance test our services and not get in trouble!

When mounted in an app, it will add additional endpoints which when called will 'mock' the functionality of the external service.

Things to note

- We have gone with an engine rather than an additional service, to simplify management of mocking in our environments
- The mocks do not replicate all functionality an external service provides, only the features we use in our services

## Prerequisites

Make sure you already have:

- Ruby 2.4.2
- [Bundler](http://bundler.io/) – for installing Ruby gems

# Mounting the engine

Add the engine to your Gemfile:

```ruby
gem "defra_ruby_mocks",
    git: "https://github.com/DEFRA/defra-ruby-mocks"
```

Install it with `bundle install`.

Then mount the engine in your routes.rb file:

```ruby
Rails.application.routes.draw do
  mount DefraRuby::Mocks::Engine => "/"
end
```

The engine should now be mounted at the root of your project. You can change `"/"` to a different route if you'd prefer it to be in a subdirectory.

## Installation

You don't need to do this if you're just mounting the engine without making any changes.

However, if you want to edit the engine, you'll have to install it locally.

Clone the repo and drop into the project:

```bash
git clone https://github.com/DEFRA/defra-ruby-mocks.git && cd defra-ruby-mocks
```

Then install the dependencies with `bundle install`.

## Testing the engine

The engine is mounted in a dummy Rails 4 app (in /spec/dummy) so we can properly test its behaviour.

The test suite is written in RSpec.

To run all the tests, use `bundle exec rspec`.

## Contributing to this project

If you have an idea you'd like to contribute please log an issue.

All contributions should be submitted via a pull request.

## License

THIS INFORMATION IS LICENSED UNDER THE CONDITIONS OF THE OPEN GOVERNMENT LICENCE found at:

<http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3>

The following attribution statement MUST be cited in your products and applications when using this information.

> Contains public sector information licensed under the Open Government license v3

### About the license

The Open Government Licence (OGL) was developed by the Controller of Her Majesty's Stationery Office (HMSO) to enable information providers in the public sector to license the use and re-use of their information under a common open licence.

It is designed to encourage use and re-use of information freely and flexibly, with only a few conditions.
