FROM ruby:2.4

COPY . /make-me-an-artist

WORKDIR /make-me-an-artist

RUN apt-get update && apt-get install -y \
    git && \
    rm -rf /var/lib/apt/lists/*

RUN bundle install --deployment --without test 

ENTRYPOINT ["bundle", "exec", "bin/make_me_an_artist"]
