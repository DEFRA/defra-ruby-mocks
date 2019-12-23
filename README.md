# Defra Ruby Mocks

[![Build Status](https://travis-ci.com/DEFRA/defra-ruby-mocks.svg?branch=master)](https://travis-ci.com/DEFRA/defra-ruby-mocks)
[![Maintainability](https://api.codeclimate.com/v1/badges/8b14cc1e0e1c1d6a33cc/maintainability)](https://codeclimate.com/github/DEFRA/defra-ruby-mocks/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/8b14cc1e0e1c1d6a33cc/test_coverage)](https://codeclimate.com/github/DEFRA/defra-ruby-mocks/test_coverage)
[![security](https://hakiri.io/github/DEFRA/defra-ruby-mocks/master.svg)](https://hakiri.io/github/DEFRA/defra-ruby-mocks/master)
[![Licence](https://img.shields.io/badge/Licence-OGLv3-blue.svg)](http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3)

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

## Mounting the engine

Add the engine to your Gemfile:

```ruby
gem "defra_ruby_mocks",
    git: "https://github.com/DEFRA/defra-ruby-mocks"
```

Install it with `bundle install`.

Then mount the engine in your routes.rb file:

```ruby
Rails.application.routes.draw do
  mount DefraRuby::Mocks::Engine => "/mocks"
end
```

The engine should now be mounted at `/mocks` of your project. You can change `"/mocks"` to a different route if you'd prefer it to be elsewhere.

## Mocks

The project currently mocks the following services.

### Companies House

When mounted into an app you can make requests to `/mocks/company/[company number]` to get a response that matches what our apps expect.

This is an important distinction to note. When our apps like the [Waste Exemptions front office](https://github.com/DEFRA/waste-exemptions-front-office) make a real request to Companies House, they get a lot more information back in the JSON reponse. However the only thing they are interested in is the value of `"company_status"`.

So rather than maintain a lot of unused JSON data, the mock just returns that bit of the JSON.

```bash
curl http://localhost:3000/mocks/company/SC123456
{
    "company_status": "active"
}
```

#### Company numbers

As long as the request is for a valid number the mock will return the status as `"active"`. (see <https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/426891/uniformResourceIdentifiersCustomerGuide.pdf> for details of valid number formats).

The exceptions to this are the 'special' numbers listed below. Use them if you are looking for alternate responses.

- `05868270` will return `"dissolved"`
- `04270505` will return `"administration"`
- `99999999` will mock a not found result and return a 404 error
- `88888888` will return `"liquidation"`
- `77777777` will return `"receivership"`
- `66666666` will return `"converted-closed"`
- `55555555` will return `"voluntary-arrangement"`
- `44444444` will return `"insolvency-proceedings"`
- `33333333` will return `"open"`
- `22222222` will return `"closed"`

The list of possible statuses was taken from

- [Companies House API](https://developer.companieshouse.gov.uk/api/docs/company/company_number/companyProfile-resource.html)
- [Companies House API enumerations](https://github.com/companieshouse/api-enumerations/blob/master/constants.yml)

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
