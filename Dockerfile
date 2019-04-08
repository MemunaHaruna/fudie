FROM ruby:2.4.1

# set working directory
RUN mkdir /fudie-api-container
WORKDIR /fudie-api-container

# install gems
RUN echo "Installing dependencies..."
COPY Gemfile /fudie-api-container/Gemfile
COPY Gemfile.lock /fudie-api-container/Gemfile.lock
RUN bundle install

# Remove a potentially pre-existing server.pid for Rails.
RUN rm -f /fudie-api-container/tmp/pids/server.pid

# copy files into working directory
COPY . /fudie-api-container

# Add a script to be executed every time the container starts.
CMD ["bash", "/fudie-api-container/docker-entrypoint.sh"]
