module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    # def as_indexed_json(_options = {})
    #   as_json(only: %i[title body])
    # end

    settings settings_attributes do
     # https://www.elastic.co/guide/en/elasticsearch/reference/current/null-value.html
     # https://stackoverflow.com/questions/39610803/providing-null-value-for-elasticsearch-date-field

      mappings dynamic: false do
        indexes :title, type: :text, analyzer: :autocomplete
        indexes :body, type: :text, analyzer: :autocomplete
        indexes :state, type: :text
        indexes :user_id, type: :keyword
        indexes :parent_id, type: :keyword, null_value: 'NULL'
        indexes :deactivated_by_admin, type: :boolean
        indexes :deleted_at, type: :date, null_value: '1970-01-01T00:00:00Z'
      end
    end

    def self.search(query, filters = {})
      set_filters = lambda do |context_type, query_filter|
        @search_definition[:query][:bool][context_type].push query_filter
      end

      @search_definition = {
        query: {
          bool: {
            must: [],
            should: [],
            filter: []
          }
        }
      }

      if query.blank?
        set_filters.call(:must, match_all: {})
      else
        set_filters.call(
          :must,
          multi_match: {
            fields: ['title', 'body'],
            query: query,
            fuzziness: 1,
          }
        )
      end

      if filters[:state].present?
        # returns posts based on the enum value: [draft published hidden]
        set_filters.call(:filter, term: { state: filters[:state] })
      end

      if filters[:posts_only].present?
        # returns posts which may have comments, but are not comments themselves
        set_filters.call(:filter, term: { parent_id: 'NULL' })
      end

      if filters[:active].present?
        set_filters.call(:filter, term: { deactivated_by_admin: FALSE })
        set_filters.call(:filter, term: { deleted_at: '1970-01-01T00:00:00Z' })
      end

      if filters[:user_id].present?
        set_filters.call(:filter, term: { user_id: filters[:user_id] })
      end

      __elasticsearch__.search(@search_definition)
    end
  end

  class_methods do
    def settings_attributes
      {
        index: {
          analysis: {
            analyzer: {
              autocomplete: {
                type: :custom,
                tokenizer: :standard,
                filter: %i[lowercase autocomplete]
              }
            },
            filter: {
              autocomplete: {
                type: :edge_ngram,
                min_gram: 2,
                max_gram: 25
              }
            }
          }
        }
      }
    end
  end
end
