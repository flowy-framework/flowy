[
  import_deps: [:open_api_spex, <%= if @ecto do %>:ecto, :ecto_sql, <% end %>:phoenix],<%= if @ecto do %>
  subdirectories: ["priv/*/migrations"],<% end %><%= if @html do %>
  plugins: [Phoenix.LiveView.HTMLFormatter],<% end %>
  inputs: [<%= if @html do %>"*.{heex,ex,exs}", "{config,lib,test}/**/*.{heex,ex,exs}"<% else %>"*.{ex,exs}", "{config,lib,test}/**/*.{ex,exs}"<% end %><%= if @ecto do %>, "priv/*/seeds.exs"<% end %>],
  export: [
    locals_without_parens: [
      assert_enqueued: 1,
      assert_enqueued: 2,
      refute_enqueued: 1,
      refute_enqueued: 2
    ]
  ],
  locals_without_parens: [
    assert_enqueued: 1,
    assert_enqueued: 2,
    refute_enqueued: 1,
    refute_enqueued: 2
  ]
]
