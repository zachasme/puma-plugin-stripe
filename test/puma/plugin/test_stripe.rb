# frozen_string_literal: true

require "test_helper"
require "puma"
require "puma/configuration"
require "puma/launcher"

class Puma::Plugin::TestStripe < Minitest::Test
  def setup
    Stripe.api_key = ENV["TEST_STRIPE_API_KEY"]

    @called = false

    config = Puma::Configuration.new do |c|
      c.app do |env|
        payload = env["rack.input"].read
        secret = Puma::Plugin::Stripe.signing_secret(Stripe.api_key)
        signature = env["HTTP_STRIPE_SIGNATURE"]
        Stripe::Webhook.construct_event(
          payload, signature, secret
        )
        @called = true
        [ 200, { "Content-Type" => "text/plain" }, [ "Hello, Stripe CLI!" ] ]
      end
      c.plugin "stripe"
      c.port 9292
    end

    @launcher = Puma::Launcher.new(config)
    @thread = Thread.new do
      Thread.current.abort_on_exception = true
      @launcher.run
    end
    sleep 3
  end

  def teardown
    @launcher.stop
    @thread.join
  end

  def test_registration
    `stripe --api-key #{Stripe.api_key} trigger customer.created`
    sleep 2
    assert @called
  end
end
