defmodule <%= @web_namespace %>.Live.Tools.JobLive.Index do
  use <%= @web_namespace %>, :live_view

  alias <%= @web_namespace %>.Tools.JobLive.JobFilterSchema
  alias <%= @app_module %>.Support.Oban.Jobs

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:context, :launchpad)
     |> assign(:section, :launchpad)
     |> assign_breadcrumb_steps()
     |> assign_defaults()
     |> assign_workers()
     |> assign_states()
     |> assign_queues()
     |> assign_filter_form()
     |> assign_filter()
     |> assign_jobs()}
  end

  defp assign_filter_form(socket) do
    changeset = JobFilterSchema.changeset(%JobFilterSchema{}, %{})

    socket
    |> assign(:job_filter_changeset, changeset)
    |> assign(:filter_form, to_form(changeset))
  end

  defp assign_breadcrumb_steps(socket) do
    socket
    |> assign(:steps, Breadcrumb.tools("Jobs", ""))
  end

  def assign_defaults(socket) do
    changeset = JobFilterSchema.changeset(%JobFilterSchema{}, %{})

    socket
    |> assign(:last_updated_at, nil)
    |> assign(:job_filter_changeset, changeset)
  end

  def assign_filter(%{assigns: %{job_filter_changeset: changeset}} = socket) do
    job_filter =
      changeset
      |> Ecto.Changeset.apply_changes()
      |> Map.from_struct()

    socket
    |> assign(:job_filter, job_filter)
  end

  def assign_jobs(%{assigns: %{job_filter: job_filter}} = socket) do
    # fetch_jobs_async(job_filter)

    socket
    |> assign(:jobs, Jobs.search(job_filter))
    |> assign(last_updated_at: DateTime.utc_now())
  end

  # def fetch_jobs_async(job_filter) do
  #   Task.async(fn ->
  #     :timer.sleep(2000)
  #     <%= @app_module %>.Support.Oban.Jobs.search(job_filter)
  #   end)
  # end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, "View Job")
     |> assign(:job, <%= @app_module %>.Support.Oban.Jobs.get!(id))}
  end

  @impl true
  def handle_params(_params, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, "View Job")}
  end

  @impl true
  def handle_event("validate", %{"job_filter_schema" => params}, socket) do
    changeset =
      JobFilterSchema.changeset(%JobFilterSchema{}, params)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(filter_form: to_form(changeset))
     |> assign(job_filter_changeset: changeset)
     |> assign_filter()
     |> assign_jobs()}
  end

  @impl true
  def handle_event("search", _, socket) do
    {:noreply,
     socket
     |> assign_jobs()}
  end

  # @impl true
  # def handle_info({ref, jobs}, %{assigns: %{job_filter: job_filter}} = socket) do
  #   Process.demonitor(ref, [:flush])
  #   fetch_jobs_async(job_filter)
  #   {:noreply, assign(socket, jobs: jobs, last_updated_at: DateTime.utc_now())}
  # end

  def state_color("completed"), do: :success
  def state_color("executing"), do: :primary
  def state_color("scheduled"), do: :info
  def state_color("discarded"), do: :error
  def state_color("retryable"), do: :warning
  def state_color(_), do: :default

  def format_date(nil), do: "Updated at: N/A"

  def format_date(date) do
    updated_at = date |> Timex.format!("{h24}:{m}:{s}")
    "Updated: #{updated_at}"
  end

  defp assign_workers(socket) do
    socket
    |> assign(:workers, JobFilterSchema.workers())
  end

  defp assign_states(socket) do
    socket
    |> assign(:states, JobFilterSchema.states())
  end

  defp assign_queues(socket) do
    socket
    |> assign(:queues, JobFilterSchema.queues())
  end
end
