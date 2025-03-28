# frozen_string_literal: true

require "stripe"
require "puma/plugin"

module Puma::Plugin::Stripe
  def self.signing_secret(api_key)
    secret = `stripe listen --api-key "#{api_key}" --print-secret`.chomp
    return nil unless $?.success?
    secret unless secret.empty?
  rescue
    nil
  end
end

Puma::Plugin.create do
  def start(launcher)
    @launcher = launcher

    launcher.events.on_booted do
      launcher.log_writer.log "Stripe: forwarding webhooks to #{forward_to}"
      @pid = fork do
        exec "stripe listen --forward-to #{forward_to} --api-key #{Stripe.api_key}"
      rescue Errno::ENOENT
        launcher.log_writer.log "[Stripe] Not found. See https://docs.stripe.com/stripe-cli#install"
      end
    end

    launcher.events.on_stopped { stop_stripe }
  end

  private
    def stop_stripe
      Process.waitpid(@pid, Process::WNOHANG)
      @launcher.log_writer.log "[Stripe] Stopping..."
      Process.kill(:INT, @pid) if @pid
      Process.wait(@pid)
    rescue Errno::ECHILD, Errno::ESRCH
    end

    def forward_to
      path = @launcher.options.fetch(:stripe_forward_to, "/stripe_events")
      _, port, host = @launcher.binder.ios.first.addr
      URI::HTTP.build(port:, host:, path:)
    end
end

module Puma
  class DSL
    def stripe_forward_to(path)
      @options[:stripe_forward_to] = path
    end
  end
end
