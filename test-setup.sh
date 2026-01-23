#!/bin/bash

# test-setup.sh - Setup script for Heroku CI with Elasticsearch
# This script should be run as part of your CI test-setup phase

set -e

echo "-----> Setting up test environment with Elasticsearch"

# Wait for Elasticsearch to be ready
if [ -f "$HOME/.elasticsearch/wait-for-elasticsearch.sh" ]; then
  echo "Waiting for Elasticsearch to be ready..."
  bash "$HOME/.elasticsearch/wait-for-elasticsearch.sh"
else
  echo "Elasticsearch wait script not found, waiting 10 seconds..."
  sleep 10
fi

# Verify Elasticsearch connection
echo "Verifying Elasticsearch connection..."
if curl -s http://127.0.0.1:9200/_cluster/health > /dev/null; then
  echo "✓ Elasticsearch is ready"
  curl -s http://127.0.0.1:9200/_cluster/health | jq .
else
  echo "✗ Elasticsearch is not responding"
  exit 1
fi

# Run Rails database setup
if [ -f "Rakefile" ]; then
  echo "Setting up Rails database..."
  bundle exec rake db:create db:schema:load
fi

# Create Elasticsearch test indices if needed
if [ -f "lib/tasks/elasticsearch.rake" ]; then
  echo "Setting up Elasticsearch indices..."
  bundle exec rake elasticsearch:create_indices
fi

echo "-----> Test environment setup complete"
