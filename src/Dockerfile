FROM ruby:2.4.1

# install environment dependencies
RUN apt-get update -yqq \
  && apt-get install -yqq --no-install-recommends \
    apt-utils \
    nodejs \
    npm \
    libpq-dev \
  && apt-get -q clean

# set working directory
RUN mkdir /usr/src/app
WORKDIR /usr/src/app

# install app dependencies
ADD Gemfile /usr/src/app/Gemfile
ADD Gemfile.lock /usr/src/app/Gemfile.lock
RUN bundle install

ADD . /usr/src/app

CMD ["bundle", "exec", "rails", "s", "-p", "3002", "-b", "'0.0.0.0'"]
