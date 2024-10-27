defmodule <%= @web_namespace %>.Live.Tools.JobLive.JobFormComponent do
  use <%= @web_namespace %>, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.card>
        <.simple_form id="job-form" target={@myself} event="cancel">
          <div class="space-y-2">
            <.card_field label="ID" value={@job.id} />
            <.card_field label="Worker" value={@job.worker} />
            <.card_field label="State" value={@job.state} />
            <.card_field label="Queue" value={@job.queue} />
            <.card_field label="Attempts" value={"#{@job.attempt}/#{@job.max_attempts}"} />
            <.card_formatted_field label="Inserted At" value={@job.inserted_at} />
            <.card_formatted_field label="Scheduled At" value={@job.scheduled_at} />
            <.card_formatted_field label="Attempted At" value={@job.attempted_at} />
            <.card_formatted_field label="Completed At" value={@job.completed_at} />
            <p class="text-xs font-medium text-slate-700 line-clamp-1 dark:text-navy-100">
              <pre>
                    <%= inspect(@job.errors, pretty: true) %>
                </pre>
            </p>
          </div>
          <:actions>
            <.cancel_button cancel_url={@patch} />
            <.delete_modal_button label="Cancel" />
          </:actions>
        </.simple_form>
      </.card>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end

  @impl true
  def handle_event("cancel", _params, %{assigns: %{job: %{id: id}}} = socket) do
    <%= @app_module %>.Support.Oban.Jobs.cancel_job(id)

    {:noreply,
     socket
     |> put_flash(:info, "Job canceled successfully")
     |> redirect(to: socket.assigns.patch)}
  end
end
