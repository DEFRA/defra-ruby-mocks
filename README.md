# Defra Ruby Mocks

![Build Status](https://github.com/DEFRA/defra-ruby-mocks/workflows/CI/badge.svg?branch=main)
[![Maintainability Rating](https://sonarcloud.io/api/project_badges/measure?project=DEFRA_defra-ruby-mocks&metric=sqale_rating)](https://sonarcloud.io/dashboard?id=DEFRA_defra-ruby-mocks)
[![Coverage](https://sonarcloud.io/api/project_badges/measure?project=DEFRA_defra-ruby-mocks&metric=coverage)](https://sonarcloud.io/dashboard?id=DEFRA_defra-ruby-mocks)
[![Licence](https://img.shields.io/badge/Licence-OGLv3-blue.svg)](http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3)

A Rails Engine used by the [Ruby services team](https://github.com/DEFRA/ruby-services-team) in their digital services.

We use it to mock external services such as Companies House, so we can performance test our services and not get in trouble!

When mounted in an app, it will add additional endpoints which when called will 'mock' the functionality of the external service.

Things to note

- We have gone with an engine rather than an additional service, to simplify management of mocking in our environments
- The mocks do not replicate all functionality an external service provides, only the features we use in our services

## Prerequisites

Make sure you already have:

- Ruby 2.7.1
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
  mount DefraRubyMocks::Engine => "/mocks"
end
```

The engine should now be mounted at `/mocks` of your project. You can change `"/mocks"` to a different route if you'd prefer it to be elsewhere.

## Configuration

For the mock routes to be accessible you'll also need to enable them.

```ruby
# config/initializers/defra_ruby_mocks.rb
require "defra_ruby_mocks"

DefraRubyMocks.configure do |config|
  config.enable = true
  config.delay = 1000
end
```

To protect against having them enabled when in production, by default the engine will not allow access unless they have been enabled in the config.

We also provide an option to control how long the mock should delay before responding. The default is 1000ms (1 second).

## Mocks

The project currently mocks the following services.

### Companies House

When mounted into an app you can make requests to `/mocks/company/[company number]` to get a response that matches what our apps expect.

This is an important distinction to note. When our apps like the [Waste Exemptions front office](https://github.com/DEFRA/waste-exemptions-front-office) make a real request to Companies House, they get a lot more information back in the JSON reponse. However the only things they are interested in are the value of `"company_name"`, `"company_status"`, `"company_type"` and `"registered_office"`, .

So rather than maintain a lot of unused JSON data, the mock just returns those bits of the JSON.

```bash
curl http://localhost:3000/mocks/company/SC123456
{
    "company_name": "Acme Industries",
    "company_status": "active",
    "company_type": "ltd",
    "registered_office_address": {
        "address_line_1": "10 Downing St",
        "address_line_2": "Horizon House",
        "locality": "Bristol",
        "postal_code": "BS1 5AH"
    }
}
```

Additionally, an Officers endpoint is available at `/mocks/company/[company number]/officers`. This returns a list of partial Officer data, eg:
```bash
curl http://localhost:3000/mocks/company/SC123456/officers
{
   "items": [
    {
      "name": "APPLE, Alice",
      "officer_role": "director"
    },
    {
      "name": "BANANA, Bob",
      "officer_role": "director"
    },...
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

Additionally, an `"active"` LLP company can be retrieved by using the following registration numbers:

- `XX999999`
- `YY999999`

The list of possible statuses was taken from

- [Companies House API](https://developer.companieshouse.gov.uk/api/docs/company/company_number/companyProfile-resource.html)
- [Companies House API enumerations](https://github.com/companieshouse/api-enumerations/blob/master/constants.yml)

### Govpay

When mounted into an app you can simulate interacting with the Govpay hosted pages service. The following endpoints are supported:

- `POST /govpay/v1/payments`
  - Create a payment. In its current form it always returns a fixed (success) response regardless of the input parameters.
- `GET /govpay/v1/payments/:payment_id`
  - Get details of an existing payment. The response includes the payment_id from the input parameters, a random amount, and the current time as created_at value.
- `POST /govpay/v1/payments/:payment_id/refunds`
  - Request a refund. The response includes the amount from the input parameters and a status of "submitted", meaning that the refund is pending. It also writes the current time to a temporary file to support refund details checking - see *Govpay refund status* below.
- `GET /govpay/v1/payments/:payment_id/refunds/:refund_id`
  - Get the details of an existing refund. This currently returns a fixed response, with the exception of the `status` value. See *Govpay refund status* below.

#### Govpay refund status
The Govpay service behaves differently in production and in test (sandbox) modes.
- In **production**, a refund is initially assigned a status of `submitted` and this is the `status` value that will be received in the response to a successful create refund request. When the payment provider processes the refund, the status within the Govpayservice will be updated to `success`. 
- In **sandbox** mode, a refund will be assigned a status of `success` as soon as it is created.

This causes issues for testing, as it is not possible to test behaviour around `submitted` (i.e. pending) refunds. To mitigate this, the mock API for getting refund details behaves as follows:
- Default: Return success
- If the environment variable `GOVPAY_REFUND_SUBMITTED_SUCCESS_LAG` is set (integer value):
  - If fewer than that number of seconds has elapsed since the most recent refund request, return submitted
  - If greater than that number of seconds has elapsed since the most recent refund request, return success

So setting the `GOVPAY_REFUND_SUBMITTED_SUCCESS_LAG` variable should allow a developer or tester to simulate production behaviour. The iniital response will be `submitted`; checking the refund status before the specified lag has passed will also return `submitted`; and checking the refund status after the lag has passed will return `success`.

#### Payments

Making a payment with Govpay requires three steps:

1. The app sends a JSON request to Govpay asking it to prepare for a new payment, and providing a unique identifier and a callback URL.
2. Govpay subsequently invokes the callback URL, passing a Govpay URL to which the user should be redirected.
2. The app redirects the user to the Govpay URL with params that tell Govpay where to redirect the user to when the payment is complete.

This Govpay mock replicates those 2 interactions with the following url
- `../govpay/v1/payments`

#### Configuration

In order to use the govpay mock you'll need to provide additional configuration details.
- The root Govpay mock URLs for both front- and back-office. Both are required because the mocks for front-office point at back-office and vice-versa, and the mock gem needs to know both values for the two hosting applications.
- The external URL for both applications. These are required because the mock gem needs to map from internal-EC2 only URLs to externally accessible URLs.

For example, for a front-office application, where the front-office and back-office mocks are mounted on `/fo/mocks` and `/bo/mocks` respectively:

```ruby
config/initializers/defra_ruby_mocks.rb
require "defra_ruby_mocks"

DefraRubyMocks.configure do |config|
  configuration.govpay_mocks_external_root_url = ENV.fetch("MOCK_FO_GOVPAY_URL", "https://back-office.domain.cloud/bo/mocks/govpay/v1")
  configuration.govpay_mocks_external_root_url_other = ENV.fetch("MOCK_BO_GOVPAY_URL", "https://front-office.domain.cloud/fo/mocks/govpay/v1")

  configuration.govpay_mocks_internal_root_url = ENV.fetch("MOCK_FO_GOVPAY_URL_INTERNAL", "https://back-office-internal.domain.cloud:8001/bo/mocks/govpay/v1")
  configuration.govpay_mocks_internal_root_url_other = ENV.fetch("MOCK_BO_GOVPAY_URL_INTERNAL", "https://front-office-internal.domain.cloud:8002/fo/mocks/govpay/v1")
end
```

You'll also need to provide AWS configuration details for the mocks, for example:

```ruby
require "defra_ruby/aws"

DefraRuby::Aws.configure do |c|
  govpay_mocks_bucket = {
    name: ENV.fetch("AWS_DEFRA_RUBY_MOCKS_BUCKET", nil),
    region: ENV.fetch("AWS_REGION", nil),
    credentials: {
      access_key_id: ENV.fetch("AWS_DEFRA_RUBY_MOCKS_ACCESS_KEY_ID", nil),
      secret_access_key: ENV.fetch("AWS_DEFRA_RUBY_MOCKS_SECRET_ACCESS_KEY", nil)
    },
    encrypt_with_kms: ENV.fetch("AWS_DEFRA_RUBY_MOCKS_ENCRYPT_WITH_KMS", nil)
  }

  c.buckets = [govpay_mocks_bucket]
end
```

```ruby
mount DefraRubyMocks::Engine => "/mocks"
```

#### Only for Waste Carriers

At this time there is only one digital service built using Ruby on Rails that uses Govpay; the [Waste Carriers Registration service](https://github.com/DEFRA/ruby-services-team/tree/master/services/wcr). So the Govpay mock has been written with the assumption it will only be mounted into one of the Waste Carriers apps.

A critical aspect of this is the expectation that the following classes will be loaded and available when the engine is mounted and the app is running

- `WasteCarriersEngine::TransientRegistration`
- `WasteCarriersEngine::Registration`

#### Payment pages are not mocked

The actual Govpay service presents payment pages that display a form where users are able to enter their credit card details and confirm the payment is correct. This mock does **not** replicate the UI of Govpay, only the API. Bear this in mind when building any automated acceptance tests.

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
