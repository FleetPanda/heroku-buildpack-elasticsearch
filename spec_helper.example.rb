# spec/spec_helper.rb - Example configuration for Rails tests with Elasticsearch

require 'rspec/rails'
require 'elasticsearch'

# Elasticsearch configuration for tests
RSpec.configure do |config|
  # Use color in output
  config.color = true
  config.formatter = :progress

  # Setup Elasticsearch client
  config.before(:suite) do
    # Wait for Elasticsearch to be ready
    Elasticsearch::Client.new(hosts: ['localhost:9200']).ping
    
    # Optional: Create test indices
    # You can add index setup here if needed
  end

  # Clean up Elasticsearch after each test
  config.after(:each) do
    # Optional: Delete test indices or documents
    # client = Elasticsearch::Client.new(hosts: ['localhost:9200'])
    # client.indices.delete(index: 'test-*')
  end
end

# Elasticsearch client helper
def elasticsearch_client
  @elasticsearch_client ||= Elasticsearch::Client.new(
    hosts: [ENV['ELASTICSEARCH_URL'] || 'localhost:9200']
  )
end

# Wait for Elasticsearch to be available
def wait_for_elasticsearch(timeout: 30)
  start_time = Time.now
  loop do
    begin
      elasticsearch_client.ping
      return true
    rescue => e
      if Time.now - start_time > timeout
        raise "Elasticsearch not available after #{timeout} seconds: #{e.message}"
      end
      sleep 0.5
    end
  end
end
