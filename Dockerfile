ARG MIX_ENV="prod"

FROM hexpm/elixir:hexpm/elixir:1.15.7-erlang-26.1.2-debian-bullseye-20230612-slim AS build

# RUN apt-get update && \
#   apt-get install -y curl

# RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -

RUN apt-get update && apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
    build-essential git curl npm && \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

# RUN npm install npm@8.5.3 -g

# Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Create app directory and copy the Elixir projects into it
RUN mkdir /app
WORKDIR /app

# set build ENV
ARG MIX_ENV
ARG GITHUB_TOKEN

# set build ENV
ENV MIX_ENV="${MIX_ENV}"

# install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get --only $MIX_ENV
RUN mix deps.compile

# build project and compile
COPY lib lib

RUN mix do compile, release

# prepare release image
FROM hexpm/elixir:hexpm/elixir:1.15.7-erlang-26.1.2-debian-bullseye-20230612-slim

# install runtime dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
    # Runtime dependencies
    build-essential ca-certificates libncurses5-dev \
    # In case someone uses `Mix.install/2` and point to a git repo
    git \
    # Additional standard tools
    wget && \
    # We need it to check the state of the db server
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

ENV MIX_ENV=prod

# prepare app directory
RUN mkdir /app
WORKDIR /app

# extend hex timeout
ENV HEX_HTTP_TIMEOUT=20

# Install hex and rebar for `Mix.install/2` and Mix runtime
RUN mix local.hex --force && \
    mix local.rebar --force

# copy release to app container
COPY --from=build /app/_build/prod/rel/flowy .
RUN chown -R nobody: /app
USER nobody

ENV HOME=/app