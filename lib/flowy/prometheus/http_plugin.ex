defmodule Flowy.Prometheus.HttpPlugin do
  @moduledoc """
  This module is responsible for generating metrics for the HTTP module.
  """
  use PromEx.Plugin

  @stop_event [:flowy, :http, :stop]

  @impl true
  def event_metrics(opts) do
    [
      http_events(opts)
    ]
  end

  defp http_events(opts) do
    app = Keyword.get(opts, :otp_app)
    http_metrics_tags = [:scheme, :host, :port, :path, :query, :method]
    duration_unit = :millisecond
    duration_unit_plural = PromEx.Utils.make_plural_atom(duration_unit)

    Event.build(
      :flowy_http_event_metrics,
      [
        # Capture request duration information
        distribution(
          [app, :flowy, :http, :request, :duration, duration_unit_plural],
          event_name: @stop_event,
          measurement: :duration,
          description: "The time it takes for the Http module to respond to HTTP requests.",
          reporter_options: [
            buckets: [10, 100, 500, 1_000, 5_000, 10_000, 30_000]
          ],
          tag_values: &htpp_metrics_values/1,
          tags: http_metrics_tags,
          unit: {:native, duration_unit}
        ),

        # Capture the number of requests that have been serviced
        counter(
          [app, :flowy, :http, :requests, :total],
          event_name: @stop_event,
          description: "The number of requests have been serviced.",
          tag_values: &htpp_metrics_values/1,
          tags: http_metrics_tags
        )
      ]
    )
  end

  defp htpp_metrics_values(%{
         scheme: scheme,
         host: host,
         port: port,
         path: path,
         query: query,
         method: method
       }) do
    # whitelisting attrs
    %{scheme: scheme, host: host, port: port, path: path, query: query, method: method}
  end
end
