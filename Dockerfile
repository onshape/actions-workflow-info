FROM ruby:2.7-alpine

WORKDIR /usr/src/app

RUN bundler init
RUN bundler add octokit --version="~> 4.0"

COPY ./entrypoint.rb .

ENTRYPOINT ["/usr/src/app/entrypoint.rb"]
