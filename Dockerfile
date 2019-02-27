FROM ruby:2.4.1
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev postgresql-dev nodejs

RUN mkdir /fudie-api-container
WORKDIR /fudie-api-container

COPY Gemfile /fudie-api-container/Gemfile
COPY Gemfile.lock /fudie-api-container/Gemfile.lock

RUN bundle install
COPY . /fudie-api-container

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
