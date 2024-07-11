# frozen_string_literal: true

# This class is responsible for querying the Art Museum API
class ArtMuseum
  include ActiveModel::API
  include Parsed
  attr_reader :query_terms, :service, :service_response

  def initialize(query_terms:)
    @query_terms = query_terms
    @service = 'artmuseum'
    @service_response = art_museum_service_response
  end

  private

  def art_museum_service_response
    uri = URI::HTTPS.build(host: 'data.artmuseum.princeton.edu', path: '/search',
                           query: "q=#{@query_terms}&type=all&size=3")
    response = Net::HTTP.get(uri)
    begin
      JSON.parse(response, symbolize_names: true)
    rescue JSON::ParserError
      handle_parser_error response
    end
  end

  def number
    service_response.dig(:hits, :total)
  end

  def more_link
    URI::HTTPS.build(host: 'artmuseum.princeton.edu', path: '/search/collections',
                     query: "mainSearch=\"#{query_terms}\"")
  end

  def documents
    @documents ||= service_response.dig(:hits, :hits)
  end

  def handle_parser_error(response)
    raise AllsearchError.new(
      problem: 'UPSTREAM_ERROR',
      msg: "Query to upstream failed with #{ActionController::Base.helpers.strip_tags(response)}"
    )
  end
end
