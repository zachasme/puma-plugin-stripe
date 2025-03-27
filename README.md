# Stripe Puma Plugin

Forward Stripe webhook events to your web server.

## Installation

Install the [Stripe CLI](https://docs.stripe.com/stripe-cli#install), then install the gem and add to the application's Gemfile by executing:

```bash
bundle add puma-plugin-stripe
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install puma-plugin-stripe
```

## Usage

Make sure `Stripe.api_key` is set, e.g. in `config/initializers/stripe.rb`:

```ruby
Stripe.api_key = "sk_test_..."
```

Add `plugin :stripe` to `puma.rb` configuration:

```ruby
# Run stripe cli only in development.
plugin :stripe if ENV["RAILS_ENV"] == "development"
```

By default, events will be forwarded to `/stripe_events`, this can be configured using `stripe_forward_to "/stripe/webhook"` in `puma.rb`.

You can grab your *signing secret* using `Puma::Plugin::Stripe.signing_secret`. For example:

```ruby
class StripeEventsController < ActionController::API
  before_action :set_event

  def create
    case event.type
    when 'payment_intent.succeeded'
      payment_intent = event.data.object
      # ...
    end

    head :ok
  end

  private

    def event
      @event ||= Stripe::Webhook.construct_event(
        request.body.read,
        request.headers["stripe-signature"],
        Puma::Plugin::Stripe.signing_secret(Stripe.api_key)
      )
    rescue => error
      logger.error error
      head :bad_request
    end
end

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `puma-plugin-stripe.gemspec`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/zachasme/puma-plugin-stripe.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
