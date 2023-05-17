FROM ruby:3.2.2-slim-bullseye AS base

FROM base AS deps

RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends build-essential zlib1g-dev libyaml-0-2 libyaml-dev libssl-dev libpq-dev

WORKDIR /app
RUN gem install bundler:2.4.12
COPY Gemfile Gemfile.lock ./
RUN bundle install

FROM base AS runner

ENV LANG=ja_JP.utf8
RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends libpq-dev postgresql-client-13 locales task-japanese \
    && rm -rf /var/lib/apt/lists/* \
    && echo "ja_JP.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=ja_JP.UTF-8 \
    && ln -fs /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

RUN useradd --uid 1000 --create-home rails
USER rails

WORKDIR /app
COPY --from=deps --chown=rails /usr/local/bundle /usr/local/bundle
COPY --chown=rails . .