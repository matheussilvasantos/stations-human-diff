FROM ruby:2.6-alpine

RUN apk add --update git
LABEL "com.github.actions.name"="Stations Human Diff"
LABEL "com.github.actions.description"="Creates a beautiful csv diff."
LABEL "com.github.actions.icon"="message-square"
LABEL "com.github.actions.color"="blue"

ENV RACK_ENV = production

RUN mkdir /app
WORKDIR /app
COPY Gemfile* /app/
COPY *.gemspec /app/

RUN gem install bundler
RUN bundle install --without development

COPY . /app

ENTRYPOINT ["/app/entrypoint.sh"]
