# Heroku Buildpack for Elasticsearch 7.10.2 (CI/CD)

This Heroku buildpack installs and configures Elasticsearch 7.10.2 for use in CI/CD environments, particularly with Heroku CI and Ruby on Rails applications. It is designed to be a lightweight, ephemeral solution for running Elasticsearch during your test suite, providing a reliable alternative to free add-ons.

## Features

- **Installs Elasticsearch 7.10.2**: Downloads and caches the official Elasticsearch binary.
- **Optimized for CI**: Configured for a small memory footprint (512MB heap) and single-node discovery.
- **Ruby on Rails Integration**: Includes helper scripts and examples for seamless integration with Rails apps.
- **Automatic Detection**: Detects Rails apps with Elasticsearch-related gems or a marker file.
- **Heroku CI Ready**: Provides examples for `app.json` and `heroku.yml` to get you started quickly.

## How It Works

This buildpack performs the following actions:

1.  **`bin/detect`**: Checks for a `Gemfile` containing `elasticsearch`, `searchkick`, or `tire`, or a `.elasticsearch-buildpack` file in your app's root directory. It also activates if the `ELASTICSEARCH_BUILDPACK_ENABLED` environment variable is set to `true`.
2.  **`bin/compile`**: Downloads the Elasticsearch 7.10.2 binary, caches it for future builds, and extracts it to `$BUILD_DIR/.elasticsearch`. It then creates a minimal `elasticsearch.yml` and `jvm.options` for a CI environment.
3.  **`bin/release`**: Exposes an `elasticsearch` process type that you can use in your `Procfile` or `heroku.yml`.

## Usage

To use this buildpack, you need to add it to your Heroku app's buildpacks list. You can do this via `app.json`, `heroku.yml`, or the Heroku CLI.

### Heroku CLI

```bash
# Add the buildpack to your app (replace with your GitHub repo URL)
heroku buildpacks:add https://github.com/FleetPanda/heroku-buildpack-elasticsearch.git

# Ensure the Ruby buildpack is also present
heroku buildpacks:add heroku/ruby
```

### `app.json`

If you are using Heroku CI with `app.json`, add the buildpack to the `buildpacks` array. Make sure it comes before the Ruby buildpack.

```json
{
  "name": "Your Rails App",
  "buildpacks": [
    {
      "url": "https://github.com/FleetPanda/heroku-buildpack-elasticsearch.git"
    },
    {
      "url": "heroku/ruby"
    }
  ]
}
```

### `heroku.yml`

For Heroku CI with `heroku.yml`, you can define the buildpacks in the `build` section.

```yaml
build:
  docker:
    web: Dockerfile
  config:
    ELASTICSEARCH_BUILDPACK_ENABLED: true
```

## Configuration

### Environment Variables

- **`ELASTICSEARCH_BUILDPACK_ENABLED`**: Set to `true` to force the buildpack to run, even if no Elasticsearch gems are detected.
- **`ES_JAVA_OPTS`**: Customize the JVM options for Elasticsearch. Defaults to `-Xms512m -Xmx512m`.

### Procfile

This buildpack exposes an `elasticsearch` process type. You can use it in your `Procfile` to run Elasticsearch alongside your web process.

```
elasticsearch: $ELASTICSEARCH_HOME/bin/elasticsearch
web: bundle exec puma -C config/puma.rb
```

## Ruby on Rails Integration

This buildpack is designed to work seamlessly with Rails. Here are some tips for integration.

### Gemfile

Make sure you have an Elasticsearch client gem in your `Gemfile`.

```ruby
# Gemfile
gem 'elasticsearch', '~> 7.10'
# or
gem 'searchkick', '~> 4.4'
```

### Elasticsearch Initializer

Create an initializer to configure the Elasticsearch client. This example uses the `BONSAI_URL` for production and falls back to a local URL for other environments.

```ruby
# config/initializers/elasticsearch.rb
require 'elasticsearch'

elasticsearch_url = case Rails.env
                    when 'production'
                      ENV['BONSAI_URL']
                    else
                      'http://localhost:9200'
                    end

$elasticsearch = Elasticsearch::Client.new(host: elasticsearch_url)
```

### Rake Tasks

It's helpful to have Rake tasks for managing your Elasticsearch indices. See the `elasticsearch.rake.example` file for a complete example.

### Test Environment

To use Elasticsearch in your test suite, you'll need to configure your `spec_helper.rb` or `rails_helper.rb` to start and stop Elasticsearch and manage test indices. The `spec_helper.example.rb` file provides a good starting point.

### Heroku CI `test-setup.sh`

The buildpack includes a `test-setup.sh` script that waits for Elasticsearch to be ready before running your tests. You can use this in your `app.json` or `heroku.yml`.

**`app.json` example:**

```json
{
  "scripts": {
    "test-setup": "./test-setup.sh",
    "test": "bundle exec rspec"
  }
}
```

## Development

To test this buildpack locally, you can use Docker.

```bash
# Build the Docker image
docker build -t heroku-buildpack-elasticsearch .

# Run the container
docker run -it heroku-buildpack-elasticsearch /bin/bash
```

## License

This buildpack is open-source and available under the [MIT License](LICENSE).
