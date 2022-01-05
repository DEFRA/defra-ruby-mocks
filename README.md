# Defra Ruby Mocks

![Build Status](https://github.com/DEFRA/defra-ruby-mocks/workflows/CI/badge.svg?branch=main)
[![Maintainability Rating](https://sonarcloud.io/api/project_badges/measure?project=DEFRA_defra-ruby-mocks&metric=sqale_rating)](https://sonarcloud.io/dashboard?id=DEFRA_defra-ruby-mocks)
[![Coverage](https://sonarcloud.io/api/project_badges/measure?project=DEFRA_defra-ruby-mocks&metric=coverage)](https://sonarcloud.io/dashboard?id=DEFRA_defra-ruby-mocks)
[![security](https://hakiri.io/github/DEFRA/defra-ruby-mocks/main.svg)](https://hakiri.io/github/DEFRA/defra-ruby-mocks/main)
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

This is an important distinction to note. When our apps like the [Waste Exemptions front office](https://github.com/DEFRA/waste-exemptions-front-office) make a real request to Companies House, they get a lot more information back in the JSON reponse. However the only things they are interested in are the value of `"company_status"` and `"company_type"`.

So rather than maintain a lot of unused JSON data, the mock just returns those bits of the JSON.

```bash
curl http://localhost:3000/mocks/company/SC123456
{
    "company_status": "active",
    "company_type": "ltd"
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

### Worldpay

When mounted into an app you can simulate interacting with the Worldpay hosted pages service.

#### Payments

Making a payment with Worldpay essentially comes in 2 stages

1. The app sends an XML request to Worldpay asking it to prepare for a new payment. Worldpay responds with a reference and a URL to redirect the user to
2. The app redirects the user to the URL and adds to it query params that tell Worldpay where to redirect the user to when the payment is complete

For more details check out [Making a payment with WorldPay](https://github.com/DEFRA/ruby-services-team/blob/master/services/wcr/payment_with_worldpay.md)

This Worldpay mock replicates those 2 interactions with the following urls

- `../worldpay/payments-service`
- `../worldpay/dispatcher`

##### Cancelled payments

The engine has the ability to mock a user cancelling a payment when on the Worldpay site. To have the mock return a cancelled payment response just ensure the registration's company name includes the word `cancel` (case doesn't matter).

If it does the engine will redirect back to the cancelled url instead of the success url provided, plus set the payment status to `CANCELLED`.

This allows us to test how the application handles Worldpay responding with a cancelled payment response.

##### Errored payments

The engine has the ability to Worldpay erroring during a payment. To have the mock return an errored payment response just ensure the registration's company name includes the word `error` (case doesn't matter).

If it does the engine will redirect back to the error url instead of the success url provided, plus set the payment status to `ERROR`.

This allows us to test how the application handles Worldpay responding with an errored payment response.

##### Pending payments

The engine has the ability to also mock Worldpay marking a payment as pending. To have the mock return a payment pending response just ensure the registration's company name includes the word `pending` (case doesn't matter).

If it does the engine will redirect back to the pending url instead of the success url provided, plus set the payment status to `SENT_FOR_AUTHORISATION`.

This allows us to test how the application handles Worldpay responding with a payment pending response.

##### Refused payments

The engine has the ability to also mock Worldpay refusing a payment. To have the mock refuse payment just ensure the registration's company name includes the word `reject` (case doesn't matter).

If it does the engine will redirect back to the failure url instead of the success url provided, plus set the payment status to `REFUSED`.

This allows us to test how the application handles both successful and unsucessful Worldpay payments.

##### Stuck payments

The engine has the ability to also mock Worldpay not redirecting back to the service. This is the equivalent of a registration getting 'stuck at Worldpay'. To have the mock not respond just ensure the registration's company name includes the word `stuck` (case doesn't matter).

If it does the engine will not redirect back to the service, but instead render a 'You're stuck!' page.

This allows us to test how the application handles Worldpay not returning after we redirect a user to them.

#### Refunds

Requesting a refund from Worldpay is a single step process.

1. The app sends an XML request to Worldpay with details of the order to be refunded and the amount. Worldpay returns an XML response confirming the request has been received

Like payments, refund requests are also sent to the same url `../worldpay/payments-service`. The mock handles determining what request is being made and returns the appropriate response.

#### Configuration

In order to use the Worldpay mock you'll need to provide additional configuration details

```ruby
# config/initializers/defra_ruby_mocks.rb
require "defra_ruby_mocks"

DefraRubyMocks.configure do |config|
  config.enable = true
  config.delay = 1000

  config.worldpay_admin_code = "admincode1"
  config.worldpay_mac_secret = "macsecret1"
  config.worldpay_merchant_code = "merchantcode1"
  config.worldpay_domain = "http://localhost:3000/mocks"
end
```

It's important that the admin code, mac secret and merchant code are the same as used by the apps calling the Worldpay mock. These values are used when generating the responses and are validated by the apps so it's important they match.

The domain is used when generating the URL we tell the app to redirect users to. As this is just an engine and not a standalone service, we need to tell it what domain it is running from. For example, if the engine is mounted into the app like this

```ruby
mount DefraRubyMocks::Engine => "/mocks"
```

And the app is running at `http://localhost:3000`, this engine can then use that information to tell the app to redirect users to `http://localhost:3000/mocks/worldpay/dispatcher` as part of the `payments-service` response.

#### Only for Waste Carriers

At this time there is only one digital service built using Ruby on Rails that uses Worldpay; the [Waste Carriers Registration service](https://github.com/DEFRA/ruby-services-team/tree/master/services/wcr). So the Worldpay mock has been written with the assumption it will only be mounted into one of the Waste Carriers apps.

A critical aspect of this is the expectation that the following classes will be loaded and available when the engine is mounted and the app is running

- `WasteCarriersEngine::TransientRegistration`
- `WasteCarriersEngine::Registration`

We need these classes so we can use them to query the database for the registration the payment is being made against. We only get the registration reference in the request made to `/worldpay/dispatcher`, not the order code. As the response needs to include the order code we need access to these ActiveRecord models to locate the last order added.

In the live Worldpay service this information (along with the amount to be paid) is saved after the initial request to `/payments-service`. The mock however isn't persisting anything to reduce complexity. So instead it needs to be able to query the database for the information it needs via ActiveRecord.

#### Payment pages are not mocked

The actual Worldpay service presents payment pages that display a form where users are able to enter their credit card details and confirm the payment is correct. This mock does **not** replicate the UI of Worldpay, only the API. Bear this in mind when building any automated acceptance tests.

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
