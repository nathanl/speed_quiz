FROM elixir:1.12.0-alpine AS build

# install build dependencies
RUN apk add --no-cache build-base npm git python3

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV=prod

# install mix dependencies
COPY mix.exs mix.lock ./
COPY config/config.exs config/$MIX_ENV.exs config/
# COPY config config
RUN mix do deps.get, deps.compile

# build assets
COPY assets/package.json assets/package-lock.json ./assets/
RUN npm --prefix ./assets ci --progress=false --no-audit --loglevel=error

COPY priv priv
COPY assets assets
RUN npm run --prefix ./assets deploy
RUN mix phx.digest

# compile and build release
COPY lib lib
# uncomment COPY if rel/ exists
# COPY rel rel
RUN mix compile
# Changing config/runtime doesn't require recompiling
COPY config/runtime.exs config/
RUN mix release

# prepare release image
FROM alpine:3.9 AS app
RUN apk add --no-cache openssl ncurses-libs

WORKDIR /app

RUN chown nobody:nobody /app

USER nobody:nobody

COPY --from=build --chown=nobody:nobody /app/_build/prod/rel/ ./

ENV HOME=/app
ENV MIX_ENV=prod

# build an image
# docker image build -t elixir/speed_quiz .
# 
# create a container
# docker create --name speed_quiz_container -e SECRET_KEY_BASE='Az4oh6iX/9EqfHN1gXAQr4fRFtToEY0mUmz50uUr6V63arAV8Z0T406PbcsCCfHE' -e FLY_APP_NAME='foo' --publish 4000:4000 --log-driver json-file elixir/speed_quiz
CMD ["speed_quiz/bin/speed_quiz", "start"]
# CMD ["/bin/bash"]
# CMD ["sh", "-c", "while true; do echo 'yo' && sleep 5; done;"]
