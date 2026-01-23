# config/initializers/elasticsearch.rb
# Example Elasticsearch configuration for Rails

require 'elasticsearch'

# Determine Elasticsearch URL based on environment
elasticsearch_url = case Rails.env
                    when 'production'
                      ENV['BONSAI_URL'] || 'http://localhost:9200'
                    when 'test', 'ci'
                      ENV['ELASTICSEARCH_URL'] || 'http://localhost:9200'
                    else
                      ENV['ELASTICSEARCH_URL'] || 'http://localhost:9200'
                    end

# Create Elasticsearch client
$elasticsearch = Elasticsearch::Client.new(
  hosts: [elasticsearch_url],
  retry_on_failure: true,
  retry_on_status: [502, 503, 504]
)

# Log Elasticsearch requests in development
if Rails.env.development?
  $elasticsearch.transport.logger = Logger.new(STDOUT)
  $elasticsearch.transport.logger.level = Logger::INFO
end

# Verify connection on startup
begin
  info = $elasticsearch.info
  Rails.logger.info "Elasticsearch connected: #{info['version']['number']}"
rescue => e
  Rails.logger.warn "Elasticsearch connection failed: #{e.message}"
  Rails.logger.warn "Elasticsearch will be unavailable until it starts"
end

# Helper module for Elasticsearch operations
module ElasticsearchHelper
  def self.client
    $elasticsearch
  end

  def self.index_exists?(index_name)
    client.indices.exists?(index: index_name)
  end

  def self.create_index(index_name, settings = {})
    return if index_exists?(index_name)
    
    default_settings = {
      settings: {
        number_of_shards: 1,
        number_of_replicas: 0
      }
    }
    
    client.indices.create(index: index_name, body: default_settings.merge(settings))
  end

  def self.delete_index(index_name)
    client.indices.delete(index: index_name) if index_exists?(index_name)
  end

  def self.health
    client.cluster.health
  end
end
