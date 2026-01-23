# Installation Guide

This guide walks you through setting up the Elasticsearch buildpack for your Ruby on Rails app on Heroku CI.

## Prerequisites

- A Ruby on Rails application hosted on Heroku
- Heroku CLI installed locally
- A GitHub account (to host the buildpack repository)
- An app with Elasticsearch-related gems (elasticsearch, searchkick, or tire)

## Step 1: Fork or Clone the Buildpack

First, you need to host this buildpack on GitHub so Heroku can access it.

```bash
# Clone the buildpack repository
git clone https://github.com/yourusername/heroku-buildpack-elasticsearch.git
cd heroku-buildpack-elasticsearch

# Or fork it on GitHub and clone your fork
```

## Step 2: Add the Buildpack to Your Rails App

Navigate to your Rails app directory and add the buildpack.

### Option A: Using Heroku CLI

```bash
cd /path/to/your/rails/app

# Add the buildpack (replace with your GitHub URL)
heroku buildpacks:add https://github.com/yourusername/heroku-buildpack-elasticsearch.git

# Ensure Ruby buildpack is present
heroku buildpacks:add heroku/ruby

# Verify buildpacks are in the correct order
heroku buildpacks
```

### Option B: Using `app.json`

Create or update your `app.json` file in the root of your Rails app:

```json
{
  "name": "Your App Name",
  "description": "Your Rails app with Elasticsearch",
  "buildpacks": [
    {
      "url": "https://github.com/yourusername/heroku-buildpack-elasticsearch.git"
    },
    {
      "url": "heroku/ruby"
    }
  ],
  "env": {
    "ELASTICSEARCH_BUILDPACK_ENABLED": {
      "description": "Enable Elasticsearch buildpack",
      "value": "true"
    }
  },
  "scripts": {
    "test-setup": "bash test-setup.sh",
    "test": "bundle exec rspec"
  }
}
```

### Option C: Using `heroku.yml`

Create a `heroku.yml` file in your app root:

```yaml
build:
  docker:
    web: Dockerfile
  config:
    ELASTICSEARCH_BUILDPACK_ENABLED: true

run:
  web: bundle exec puma -C config/puma.rb
  elasticsearch: $ELASTICSEARCH_HOME/bin/elasticsearch

release:
  image: web
  command:
    - bundle exec rake db:migrate

test:
  web:
    - bundle exec rspec
```

## Step 3: Configure Your Rails App

### Add Elasticsearch Gem to Gemfile

```ruby
# Gemfile
gem 'elasticsearch', '~> 7.10'
```

Then run:

```bash
bundle install
```

### Create Elasticsearch Initializer

Copy the example initializer from the buildpack:

```bash
# From buildpack directory
cp elasticsearch_initializer.example.rb /path/to/your/app/config/initializers/elasticsearch.rb
```

Edit it to match your needs:

```ruby
# config/initializers/elasticsearch.rb
require 'elasticsearch'

elasticsearch_url = case Rails.env
                    when 'production'
                      ENV['BONSAI_URL']
                    else
                      ENV['ELASTICSEARCH_URL'] || 'http://localhost:9200'
                    end

$elasticsearch = Elasticsearch::Client.new(hosts: [elasticsearch_url])
```

### Create Rake Tasks

Copy the example Rake tasks:

```bash
cp elasticsearch.rake.example /path/to/your/app/lib/tasks/elasticsearch.rake
```

## Step 4: Configure Test Environment

### Update `spec_helper.rb` or `rails_helper.rb`

Add Elasticsearch setup to your test configuration:

```ruby
# spec/rails_helper.rb or spec/spec_helper.rb

require 'elasticsearch'

RSpec.configure do |config|
  # Wait for Elasticsearch on suite startup
  config.before(:suite) do
    begin
      Elasticsearch::Client.new(hosts: ['localhost:9200']).ping
      puts "✓ Elasticsearch is ready"
    rescue => e
      puts "✗ Elasticsearch not available: #{e.message}"
      exit 1
    end
  end
end
```

### Create Test Setup Script

Copy the test setup script to your app:

```bash
cp test-setup.sh /path/to/your/app/
chmod +x /path/to/your/app/test-setup.sh
```

## Step 5: Update Procfile (Optional)

If you want to run Elasticsearch locally or in production, update your `Procfile`:

```
elasticsearch: $ELASTICSEARCH_HOME/bin/elasticsearch
web: bundle exec puma -C config/puma.rb
```

## Step 6: Test Locally (Optional)

To test the buildpack locally, you can use Docker:

```bash
# Build a test Docker image
docker run -it -v /path/to/your/app:/app ubuntu:22.04 bash

# Inside Docker:
apt-get update
apt-get install -y curl git

# Clone and test the buildpack
cd /tmp
git clone https://github.com/yourusername/heroku-buildpack-elasticsearch.git
cd heroku-buildpack-elasticsearch

# Run the detect script
bash bin/detect /app

# Run the compile script
bash bin/compile /app /tmp/cache /tmp/env
```

## Step 7: Deploy to Heroku CI

Push your changes to GitHub:

```bash
git add .
git commit -m "Add Elasticsearch buildpack for CI"
git push origin main
```

Then trigger a Heroku CI build:

```bash
# If using app.json
heroku ci:run --app your-app-name

# Or create a pull request if using GitHub integration
```

## Step 8: Verify Elasticsearch is Running

Once your build starts, you can check the logs:

```bash
heroku logs --app your-app-name --tail
```

Look for output like:

```
-----> Installing Elasticsearch 7.10.2
-----> Downloading Elasticsearch 7.10.2...
Downloaded successfully
-----> Extracting Elasticsearch...
Extracted to /app/.elasticsearch
-----> Elasticsearch 7.10.2 installation complete
```

## Troubleshooting

### Elasticsearch Not Starting

Check the logs for errors:

```bash
heroku logs --app your-app-name --tail
```

Common issues:

- **Port already in use**: Elasticsearch tries to bind to port 9200. Make sure no other service is using it.
- **Out of memory**: Increase the heap size in `ES_JAVA_OPTS` environment variable (but be careful with Heroku dyno limits).
- **Java not found**: The buildpack requires Java. Ensure the Ruby buildpack is installed.

### Tests Timing Out Waiting for Elasticsearch

Increase the timeout in your test setup script or add a longer wait:

```bash
# In test-setup.sh
MAX_ATTEMPTS=60  # Increase from 30
```

### Elasticsearch Indices Not Persisting

This is expected in CI environments. Elasticsearch data is ephemeral and will be deleted when the dyno is destroyed. Create indices fresh in each test run using Rake tasks.

## Next Steps

- Review the [README.md](README.md) for more details on configuration and usage.
- Check the example files for Rails models, initializers, and Rake tasks.
- Explore the Elasticsearch documentation for advanced configuration.
