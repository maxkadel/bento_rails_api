# frozen_string_literal: true

# This class is responsible for querying the Summon API, aka "Articles+"
class Article
  include ActiveModel::API
  include Parsed
  attr_reader :query_terms, :service

  delegate :documents, to: :service_response

  def initialize(query_terms:)
    @query_terms = query_terms
    summon_config = Rails.application.config_for(:allsearch)[:summon]
    @service = Summon::Service.new(access_id: summon_config[:access_id],
                                   secret_key: summon_config[:secret_key])
  end

  # For documentation on query parameters, see https://developers.exlibrisgroup.com/summon/apis/SearchAPI/Query/Parameters/
  def service_response
    service.search(
      's.q': query_terms, # Lucene-style queries
      's.fvf': 'ContentType,Newspaper Article,true', # Excludes newspaper articles
      's.ho': 't', # Princeton holdings only
      's.dym': 't', # Enables Did You Mean functionality
      's.ps': 3 # Limits to three documents in response
    )
  rescue Summon::Transport::TransportError => error
    handle_summon_error(error)
  end

  def number
    service_response.record_count
  end

  def more_link
    URI::HTTPS.build(host: 'princeton.summon.serialssolutions.com', path: '/search',
                     query: service_response.query.query_string)
  end

  private

  # :reek:FeatureEnvy
  def handle_summon_error(error)
    message = if error.is_a? Summon::Transport::AuthorizationError
                'Could not authenticate to the upstream Summon service'
              else
                error.message
              end
    raise AllsearchError.new(problem: 'UPSTREAM_ERROR',
                             msg: message)
  end
end
