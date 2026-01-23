# app/models/post.rb
# Example Rails model with Elasticsearch integration

class Post < ApplicationRecord
  # Associations
  belongs_to :author, class_name: 'User'
  has_many :comments, dependent: :destroy

  # Validations
  validates :title, presence: true, length: { minimum: 3, maximum: 255 }
  validates :body, presence: true, length: { minimum: 10 }
  validates :author_id, presence: true

  # Elasticsearch integration
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  # Define Elasticsearch index settings and mappings
  settings index: { number_of_shards: 1, number_of_replicas: 0 } do
    mapping do
      indexes :title, type: :text, analyzer: :standard
      indexes :body, type: :text, analyzer: :standard
      indexes :author_name, type: :keyword
      indexes :created_at, type: :date
      indexes :updated_at, type: :date
      indexes :status, type: :keyword
    end
  end

  # Custom serialization for Elasticsearch
  def as_indexed_json(options = {})
    as_json(
      only: [:id, :title, :body, :status, :created_at, :updated_at],
      include: {
        author: { only: [:id, :name] }
      }
    ).merge(
      author_name: author&.name
    )
  end

  # Search methods
  def self.search(query, options = {})
    search_definition = {
      query: {
        multi_match: {
          query: query,
          fields: ['title^2', 'body', 'author_name']
        }
      }
    }

    # Add filters if provided
    if options[:status].present?
      search_definition[:query] = {
        bool: {
          must: search_definition[:query],
          filter: { term: { status: options[:status] } }
        }
      }
    end

    # Add pagination
    search_definition[:from] = (options[:page].to_i - 1) * (options[:per_page].to_i || 20)
    search_definition[:size] = options[:per_page].to_i || 20

    __elasticsearch__.search(search_definition)
  end

  def self.search_suggestions(query)
    __elasticsearch__.search(
      query: {
        match_phrase_prefix: {
          title: query
        }
      },
      size: 10
    )
  end

  # Callbacks for automatic indexing
  after_commit on: [:create, :update] do
    __elasticsearch__.index_document
  end

  after_commit on: :destroy do
    __elasticsearch__.delete_document
  end
end

# Usage examples:
# Post.search('ruby on rails')
# Post.search('elasticsearch', status: 'published', page: 1, per_page: 20)
# Post.search_suggestions('ela')
