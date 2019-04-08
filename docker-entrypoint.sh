#!/usr/bin/env bash

# Remove a potentially pre-existing server.pid for Rails.
rm -f /fudie-api-container/tmp/pids/server.pid

echo "Running migrations..."
rails db:migrate

echo "Running seeds..."
rails db:seed

echo "Preparing test database..."
rails db:test:prepare

echo "Starting up server"
rails server -b 0.0.0.0 -p 4000
