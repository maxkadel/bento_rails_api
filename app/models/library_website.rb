# frozen_string_literal: true

class LibraryWebsite
  include Parsed

  attr_reader :query_terms

  def initialize(query_terms:)
    @query_terms = query_terms
    @website_config = Rails.application.config_for(:allsearch)[:library_website]
  end

  def self.library_website_host
    config = LibraryWebsite.website_config
    if Flipper.enabled?(:permanent_host?)
      config[:host]
    else
      config[:temporary_host]
    end
  end

  def self.website_config
    @website_config ||= Rails.application.config_for(:allsearch)[:library_website]
  end

  def documents
    service_response['content'][0..2]
  end

  def number
    service_response['content'].count
  end

  def service_response
    response = Net::HTTP.post_form(uri, 'search' => query_terms)
    response_code = response.code
    if response_code.start_with? '5'
      raise AllsearchError.new(msg: "The library website API returned a #{response_code} HTTP status code.")
    end

    @service_response ||= JSON.parse(response.body)
  end

  private

  def more_link
    URI::HTTPS.build(host: LibraryWebsite.library_website_host,
                     path: '/search',
                     query: "keys=#{query_terms}")
  end

  def uri
    URI::HTTPS.build(host: LibraryWebsite.library_website_host,
                     path: @website_config[:path])
  end
end
