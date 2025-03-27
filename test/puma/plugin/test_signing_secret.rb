# frozen_string_literal: true

require "test_helper"
require "puma"
require "puma/configuration"
require "puma/launcher"

class Puma::Plugin::TestSigningSecret < Minitest::Test
  def test_good_api_key
    assert Puma::Plugin::Stripe.signing_secret(ENV["TEST_STRIPE_API_KEY"])
  end

  def test_bad_api_key
    assert_nil Puma::Plugin::Stripe.signing_secret("bad")
  end
end
