# frozen_string_literal: true

require 'datadog/statsd'

Datadog.configure do |c|
  c.env = Rails.env
  c.service = 'allsearch-backend'
  c.tracing.report_hostname = true
  c.tracing.analytics.enabled = true
  c.tracing.enabled = Rails.env.production?
  c.tracing.report_hostname = true
  c.tracing.log_injection = true

  # From https://docs.datadoghq.com/tracing/metrics/runtime_metrics/ruby/
  # To enable runtime metrics collection, set `true`. Defaults to `false`
  # You can also set DD_RUNTIME_METRICS_ENABLED=true to configure this.
  c.runtime_metrics.enabled = true

  # Optionally, you can configure the DogStatsD instance used for sending runtime metrics.
  # DogStatsD is automatically configured with default settings if `dogstatsd-ruby` is available.
  # You can configure with host and port of Datadog agent; defaults to 'localhost:8125'.
  c.runtime_metrics.statsd = Datadog::Statsd.new

  # Rails
  c.tracing.instrument :rails

  # Redis
  c.tracing.instrument :redis

  # Net::HTTP
  c.tracing.instrument :http

  # Sidekiq
  c.tracing.instrument :sidekiq

  # Faraday
  c.tracing.instrument :faraday
end
