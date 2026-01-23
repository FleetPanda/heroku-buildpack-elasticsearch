# Troubleshooting Guide

This guide covers common issues when using the Elasticsearch buildpack for Heroku CI.

## Build Failures

### Error: "Failed to download Elasticsearch"

**Symptom**: Build log shows `Failed to download Elasticsearch from https://artifacts.elastic.co/...`

**Causes**:
- Network connectivity issue
- Elasticsearch download URL is no longer valid
- Firewall blocking the download

**Solutions**:
1. Retry the build (network issues are often temporary)
2. Check if the Elasticsearch 7.10.2 binary is still available at the official URL
3. Contact Heroku support if the issue persists

### Error: "Failed to extract Elasticsearch"

**Symptom**: Build log shows `Failed to extract Elasticsearch`

**Causes**:
- Corrupted download
- Insufficient disk space
- Tar extraction failure

**Solutions**:
1. Clear the build cache: `heroku builds:cache:purge --app your-app-name`
2. Retry the build
3. Check available disk space in your dyno

## Runtime Issues

### Elasticsearch Not Responding on Port 9200

**Symptom**: Tests fail with connection refused on `http://localhost:9200`

**Causes**:
- Elasticsearch process didn't start
- Process crashed due to memory constraints
- Port binding issue

**Solutions**:

1. Check logs for startup errors:
   ```bash
   heroku logs --app your-app-name --tail
   ```

2. Increase heap memory in `ES_JAVA_OPTS`:
   ```bash
   heroku config:set ES_JAVA_OPTS="-Xms1g -Xmx1g" --app your-app-name
   ```

3. Verify Elasticsearch is in the Procfile or heroku.yml:
   ```
   elasticsearch: $ELASTICSEARCH_HOME/bin/elasticsearch
   ```

### Out of Memory Error

**Symptom**: Build or test fails with `OutOfMemoryError` or similar Java error

**Causes**:
- Elasticsearch heap size too large for dyno
- Other processes consuming memory
- Dyno size too small

**Solutions**:

1. Reduce heap size:
   ```bash
   heroku config:set ES_JAVA_OPTS="-Xms256m -Xmx256m" --app your-app-name
   ```

2. Upgrade dyno size (if using paid dynos):
   ```bash
   heroku dyno:upgrade standard-1x --app your-app-name
   ```

3. Check memory usage:
   ```bash
   heroku ps --app your-app-name
   ```

### Elasticsearch Takes Too Long to Start

**Symptom**: Tests timeout waiting for Elasticsearch to be ready

**Causes**:
- Slow network
- Slow dyno
- Elasticsearch configuration issue

**Solutions**:

1. Increase wait timeout in `test-setup.sh`:
   ```bash
   MAX_ATTEMPTS=60  # Increase from 30
   ```

2. Check Elasticsearch logs:
   ```bash
   heroku logs --app your-app-name --tail
   ```

3. Optimize Elasticsearch configuration in `elasticsearch.yml`

## Test Failures

### Tests Can't Find Elasticsearch

**Symptom**: Test fails with `Elasticsearch::Transport::Transport::Errors::ConnectionFailed`

**Causes**:
- Elasticsearch URL not set correctly
- Elasticsearch not running
- Network connectivity issue

**Solutions**:

1. Verify `ELASTICSEARCH_URL` environment variable:
   ```bash
   heroku config --app your-app-name | grep ELASTICSEARCH
   ```

2. Check Elasticsearch is running:
   ```bash
   curl http://localhost:9200/_cluster/health
   ```

3. Update initializer to use correct URL:
   ```ruby
   # config/initializers/elasticsearch.rb
   elasticsearch_url = ENV['ELASTICSEARCH_URL'] || 'http://localhost:9200'
   $elasticsearch = Elasticsearch::Client.new(hosts: [elasticsearch_url])
   ```

### Indices Not Found During Tests

**Symptom**: Test fails with `Elasticsearch::Transport::Transport::Errors::NotFound`

**Causes**:
- Indices not created before tests run
- Indices deleted between tests
- Wrong index name

**Solutions**:

1. Create indices in test setup:
   ```bash
   # In test-setup.sh
   bundle exec rake elasticsearch:create_indices
   ```

2. Add index creation to RSpec configuration:
   ```ruby
   # spec/rails_helper.rb
   RSpec.configure do |config|
     config.before(:suite) do
       ElasticsearchHelper.create_index('posts')
     end
   end
   ```

3. Verify index name matches in code

### Tests Interfering with Each Other

**Symptom**: Tests pass individually but fail when run together

**Causes**:
- Shared Elasticsearch state
- Data not cleaned between tests
- Index conflicts

**Solutions**:

1. Clean indices between tests:
   ```ruby
   # spec/rails_helper.rb
   RSpec.configure do |config|
     config.after(:each) do
       $elasticsearch.indices.delete(index: 'test-*')
     end
   end
   ```

2. Use separate indices for each test:
   ```ruby
   # In your test
   index_name = "test-#{SecureRandom.hex(4)}"
   ElasticsearchHelper.create_index(index_name)
   ```

3. Use database transactions to isolate tests

## Configuration Issues

### Buildpack Not Detected

**Symptom**: Build doesn't use Elasticsearch buildpack even though it's configured

**Causes**:
- `bin/detect` script returns exit code 1
- Buildpack not in correct order
- Gemfile doesn't contain Elasticsearch gems

**Solutions**:

1. Verify Gemfile contains Elasticsearch gems:
   ```ruby
   gem 'elasticsearch', '~> 7.10'
   # or
   gem 'searchkick'
   # or
   gem 'tire'
   ```

2. Set environment variable to force detection:
   ```bash
   heroku config:set ELASTICSEARCH_BUILDPACK_ENABLED=true --app your-app-name
   ```

3. Check buildpack order:
   ```bash
   heroku buildpacks --app your-app-name
   ```

4. Manually test detection:
   ```bash
   bash bin/detect /path/to/app
   ```

### Wrong Elasticsearch Version

**Symptom**: Tests fail because Elasticsearch version doesn't match

**Causes**:
- Buildpack installs different version
- Cached version from previous build
- Version mismatch in configuration

**Solutions**:

1. Clear build cache:
   ```bash
   heroku builds:cache:purge --app your-app-name
   ```

2. Verify buildpack is installing correct version:
   ```bash
   heroku logs --app your-app-name | grep "Elasticsearch"
   ```

3. Check Elasticsearch version in running instance:
   ```bash
   curl http://localhost:9200/
   ```

## Getting Help

If you encounter issues not covered here:

1. Check the [README.md](README.md) for general information
2. Review Elasticsearch documentation: https://www.elastic.co/guide/en/elasticsearch/reference/7.10/index.html
3. Check Heroku documentation: https://devcenter.heroku.com/
4. Open an issue on the buildpack GitHub repository
5. Contact Heroku support for platform-specific issues

## Debugging Tips

### Enable Verbose Logging

```bash
# View build logs
heroku logs --app your-app-name --tail

# View test logs
heroku ci:debug --app your-app-name
```

### SSH into Build Container

```bash
# SSH into a running dyno
heroku ps --app your-app-name
heroku dyno:connect <dyno-id> --app your-app-name
```

### Test Buildpack Locally

```bash
# Create test directories
mkdir -p /tmp/test-app /tmp/cache /tmp/env

# Create a test Gemfile
echo "gem 'elasticsearch'" > /tmp/test-app/Gemfile

# Run detect script
bash bin/detect /tmp/test-app

# Run compile script
bash bin/compile /tmp/test-app /tmp/cache /tmp/env
```

### Check Elasticsearch Configuration

```bash
# View elasticsearch.yml
cat $ELASTICSEARCH_HOME/config/elasticsearch.yml

# View jvm.options
cat $ELASTICSEARCH_HOME/config/jvm.options
```
