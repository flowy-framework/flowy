# Directory structure

> **Requirement**: This guide expects that you have gone through the [introductory guides](https://hexdocs.pm/phoenix/installation.html) and got a Phoenix application [up and running](https://hexdocs.pm/phoenix/up_and_running.html).

When we use `mix flowy.new` to generate a new Flowy Phoenix application, it builds a top-level directory structure like this:

```console
├── _build
├── assets
├── config
├── deps
├── lib
│   ├── <%= @app_name %>
│   ├── <%= @app_name %>.ex
│   ├── <%= @app_name %>_web
│   └── <%= @app_name %>_web.ex
├── priv
└── test
```

We will go over those directories one by one:

- `_build` - a directory created by the `mix` command line tool that ships as part of Elixir that holds all compilation artifacts. As we have seen in "[Up and Running](https://hexdocs.pm/phoenix/up_and_running.html)", `mix` is the main interface to your application. We use Mix to compile our code, create databases, run our server, and more. This directory must not be checked into version control and it can be removed at any time. Removing it will force Mix to rebuild your application from scratch.

- `assets` - a directory that keeps source code for your front-end assets, typically JavaScript and CSS. These sources are automatically bundled by the `esbuild` tool. Static files like images and fonts go in `priv/static`.

- `config` - a directory that holds your project configuration. The `config/config.exs` file is the entry point for your configuration. At the end of the `config/config.exs`, it imports environment specific configuration, which can be found in `config/dev.exs`, `config/test.exs`, and `config/prod.exs`. Finally, `config/runtime.exs` is executed and it is the best place to read secrets and other dynamic configuration.

- `deps` - a directory with all of our Mix dependencies. You can find all dependencies listed in the `mix.exs` file, inside the `defp deps do` function definition. This directory must not be checked into version control and it can be removed at any time. Removing it will force Mix to download all deps from scratch.

- `lib` - a directory that holds your application source code. This directory is broken into two subdirectories, `lib/<%= @app_name %>` and `lib/<%= @app_name %>_web`. The `lib/<%= @app_name %>` directory will be responsible to host all of your business logic and business domain. It typically interacts directly with the database - it is the "Model" in Model-View-Controller (MVC) architecture. `lib/<%= @app_name %>_web` is responsible for exposing your business domain to the world, in this case, through a web application. It holds both the View and Controller from MVC. We will discuss the contents of these directories with more detail in the next sections.

- `priv` - a directory that keeps all resources that are necessary in production but are not directly part of your source code. You typically keep database scripts, translation files, images, and more in here. Generated assets, created from files in the `assets` directory, are placed in `priv/static/assets` by default.

- `test` - a directory with all of our application tests. It often mirrors the same structure found in `lib`.

## The lib/<%= @app_name %> directory

The `lib/<%= @app_name %>` directory hosts all of your business domain. Since our project does not have any business logic yet, the directory is mostly empty. You will only find the following files:

```console
lib/<%= @app_name %>
├── application.ex
├── mailer.ex
└── repo.ex
└── release.ex
└── config.ex
```

The `lib/<%= @app_name %>/application.ex` file defines an Elixir application named `<%= inspect @app_module %>.Application`. That's because at the end of the day Phoenix applications are simply Elixir applications. The `<%= inspect @app_module %>.Application` module defines which services are part of our application:

```elixir
children = [
  # Start the Telemetry supervisor
  <%= inspect @app_module %>Web.Telemetry,
  # Start the Ecto repository
  <%= inspect @app_module %>.Repo,
  # Start the PubSub system
  {Phoenix.PubSub, name: <%= inspect @app_module %>.PubSub},
  # Start the Endpoint (http/https)
  <%= inspect @app_module %>Web.Endpoint
  # Start a worker by calling: <%= inspect @app_module %>.Worker.start_link(arg)
  # {<%= inspect @app_module %>.Worker, arg}
]
```

If it is your first time with Phoenix, you don't need to worry about the details right now. For now, suffice it to say our application starts a database repository, a PubSub system for sharing messages across processes and nodes, and the application endpoint, which effectively serves HTTP requests. These services are started in the order they are defined and, whenever shutting down your application, they are stopped in the reverse order.

You can learn more about applications in [Elixir's official docs for Application](https://hexdocs.pm/elixir/Application.html).

The `lib/<%= @app_name %>/mailer.ex` file holds the `<%= inspect @app_module %>.Mailer` module, which defines the main interface to deliver e-mails:

```elixir
defmodule <%= inspect @app_module %>.Mailer do
  use Swoosh.Mailer, otp_app: :<%= @app_name %>
end
```

In the same `lib/<%= @app_name %>` directory, we will find a `lib/<%= @app_name %>/repo.ex`. It defines a `<%= inspect @app_module %>.Repo` module which is our main interface to the database. If you are using Postgres (the default database), you will see something like this:

```elixir
defmodule <%= inspect @app_module %>.Repo do
  use Ecto.Repo,
    otp_app: :<%= @app_name %>,
    adapter: Ecto.Adapters.Postgres
end
```

And that's it for now. As you work on your project, we will add files and modules to this directory.

## The lib/<%= @app_name %>\_web directory

The `lib/<%= @app_name %>_web` directory holds the web-related parts of our application. It looks like this when expanded:

```console
lib/<%= @app_name %>_web
├── controllers
│   ├── page_controller.ex
│   ├── page_html.ex
│   ├── error_html.ex
│   ├── error_json.ex
│   └── page_html
│       └── home.html.heex
├── components
│   ├── layouts.ex
│   └── layouts
│       ├── app.html.heex
│       └── root.html.heex
│       └── live.html.heex
│       └── unauthenticated.html.heex
├── endpoint.ex
├── gettext.ex
├── router.ex
└── telemetry.ex
```

All of the files which are currently in the `controllers` and `components` directories are there to create the "Welcome to Phoenix!" page we saw in the "[Up and running](up_and_running.html)" guide.

By looking at `controller` and `components` directories, we can see Phoenix provides features for handling layouts and HTML and error pages out of the box.

Besides the directories mentioned, `lib/<%= @app_name %>_web` has four files at its root. `lib/<%= @app_name %>_web/endpoint.ex` is the entry-point for HTTP requests. Once the browser accesses [http://localhost:4000](http://localhost:4000), the endpoint starts processing the data, eventually leading to the router, which is defined in `lib/<%= @app_name %>_web/router.ex`. The router defines the rules to dispatch requests to "controllers", which calls a view module to render HTML pages back to clients. We explore these layers in length in other guides, starting with the "[Request life-cycle](request_lifecycle.html)" guide coming next.

Through _Telemetry_, Phoenix is able to collect metrics and send monitoring events of your application. The `lib/<%= @app_name %>_web/telemetry.ex` file defines the supervisor responsible for managing the telemetry processes. You can find more information on this topic in the [Telemetry guide](telemetry.html).

Finally, there is a `lib/<%= @app_name %>_web/gettext.ex` file which provides internationalization through [Gettext](https://hexdocs.pm/gettext/Gettext.html). If you are not worried about internationalization, you can safely skip this file and its contents.

## The assets directory

The `assets` directory contains source files related to front-end assets, such as JavaScript and CSS. Since Phoenix v1.6, we use [`esbuild`](https://github.com/evanw/esbuild/) to compile assets, which is managed by the [`esbuild`](https://github.com/phoenixframework/esbuild) Elixir package. The integration with `esbuild` is baked into your app. The relevant config can be found in your `config/config.exs` file.

Your other static assets are placed in the `priv/static` folder, where `priv/static/assets` is kept for generated assets. Everything in `priv/static` is served by the `Plug.Static` plug configured in `lib/<%= @app_name %>_web/endpoint.ex`. When running in dev mode (`MIX_ENV=dev`), Phoenix watches for any changes you make in the `assets` directory, and then takes care of updating your front end application in your browser as you work.

Note that when you first create your Phoenix app using `mix phx.new` it is possible to specify options that will affect the presence and layout of the `assets` directory. In fact, Phoenix apps can bring their own front end tools or not have a front-end at all (handy if you're writing an API for example). For more information you can run `mix help phx.new` or see the documentation in [Mix tasks](mix_tasks.html).

If the default esbuild integration does not cover your needs, for example because you want to use another build tool, you can switch to a [custom assets build](asset_management.html#custom_builds).

As for CSS, Phoenix ships with the [Tailwind CSS Framework](https://tailwindcss.com/), providing a base setup for projects. You may move to any CSS framework of your choice. Additional references can be found in the [asset management](asset_management.md#css) guide.
