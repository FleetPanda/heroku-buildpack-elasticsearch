# Quick Start Guide

Get Elasticsearch 7.10.2 running on Heroku CI in 5 minutes.

## 1. Add the Buildpack

```bash
cd /path/to/your/rails/app

# Add buildpack (replace with your GitHub URL)
heroku buildpacks:add https://github.com/yourusername/heroku-buildpack-elasticsearch.git

# Ensure Ruby buildpack is present
heroku buildpacks:add heroku/ruby
```

## 2. Add Elasticsearch Gem

```ruby
# Gemfile
gem 'elasticsearch', '~> 7.10'
```

```bash
bundle install
```

## 3. Create Initializer

```ruby
# config/initializers/elasticsearch.rb
require 'elasticsearch'

elasticsearch_url = ENV['ELASTICSEARCH_URL'] || 'http://localhost:9200'
$elasticsearch = Elasticsearch::Client.new(hosts: [elasticsearch_url])
```

## 4. Configure Heroku CI

### Option A: Using `app.json`

```json
{
  "buildpacks": [
    {
      "url": "https://github.com/yourusername/heroku-buildpack-elasticsearch.git"
    },
    {
      "url": "heroku/ruby"
    }
  ],
  "scripts": {
    "test-setup": "bundle exec rake db:create db:migrate",
    "test": "bundle exec rspec"
  }
}
```

### Option B: Using `heroku.yml`

```yaml
build:
  docker:
    web: Dockerfile

run:
  web: bundle exec puma -C config/puma.rb
  elasticsearch: $ELASTICSEARCH_HOME/bin/elasticsearch

test:
  web:
    - bundle exec rspec
```

## 5. Test It

```bash
# Push to GitHub
git add .
git commit -m "Add Elasticsearch buildpack"
git push origin main

# Trigger Heroku CI
heroku ci:run --app your-app-name
```

## 6. Verify in Logs

```bash
heroku logs --app your-app-name --tail
```

Look for:
```
-----> Installing Elasticsearch 7.10.2
-----> Downloading Elasticsearch 7.10.2...
Downloaded successfully
-----> Extracting Elasticsearch...
Elasticsearch 7.10.2 installation complete
```

## Next Steps

- Read [INSTALLATION.md](INSTALLATION.md) for detailed setup
- Check [README.md](README.md) for configuration options
- Review [TROUBLESHOOTING.md](TROUBLESHOOTING.md) if you hit issues
- Explore example files for Rails integration

## Common Commands

```bash
# View buildpacks
heroku buildpacks --app your-app-name

# Set environment variables
heroku config:set ES_JAVA_OPTS="-Xms512m -Xmx512m" --app your-app-name

# Clear build cache
heroku builds:cache:purge --app your-app-name

# View logs
heroku logs --app your-app-name --tail

# Run CI build
heroku ci:run --app your-app-name
```

## That's It!

Your Rails app now has Elasticsearch 7.10.2 running in Heroku CI. No more unreliable free add-ons!
