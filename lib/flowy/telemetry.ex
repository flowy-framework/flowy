defmodule Flowy.Telemetry do
  @moduledoc """
  Telemetry events for Flowy.

  flowy executes the following events:

  ### Read from cache

  `[:flowy, :cache, :read]` - Executed when reading from the cache.

  #### Measurements

    * `:system_time` - The system time.

  #### Metadata

    * `:key` - The cache key
  """

  @doc false
  # emits a `start` telemetry event and returns the the start time
  def start(event, meta \\ %{}, extra_measurements \\ %{}) do
    start_time = System.monotonic_time()

    :telemetry.execute(
      [:flowy, event, :start],
      Map.merge(extra_measurements, %{system_time: System.system_time()}),
      meta
    )

    start_time
  end

  @doc false
  # Emits a stop event.
  def stop(event, start_time, meta \\ %{}, extra_measurements \\ %{}) do
    end_time = System.monotonic_time()
    measurements = Map.merge(extra_measurements, %{duration: end_time - start_time})

    :telemetry.execute(
      [:flowy, event, :stop],
      measurements,
      meta
    )
  end

  @doc false
  def exception(event, start_time, kind, reason, stack, meta \\ %{}, extra_measurements \\ %{}) do
    end_time = System.monotonic_time()
    measurements = Map.merge(extra_measurements, %{duration: end_time - start_time})

    meta =
      meta
      |> Map.put(:kind, kind)
      |> Map.put(:reason, reason)
      |> Map.put(:stacktrace, stack)

    :telemetry.execute([:flowy, event, :exception], measurements, meta)
  end

  @doc false
  # Used for reporting generic events
  def event(event, measurements, meta) do
    :telemetry.execute([:flowy, event], measurements, meta)
  end

  @doc false
  # Used to easily create :start, :stop, :exception events.
  def span(event, start_metadata, fun) do
    :telemetry.span(
      [:flowy, event],
      start_metadata,
      fun
    )
  end
end
