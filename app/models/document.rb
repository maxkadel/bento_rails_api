# frozen_string_literal: true

# A generic document class, to be subclassed with
# specific logic about getting document metadata
# from various Data structures
class Document
  def initialize(document:, doc_keys:)
    @document = document
    @doc_keys = doc_keys
  end

  def to_h
    doc_hash = {}
    @doc_keys.each do |key|
      val = send key
      doc_hash[key] = val if val
    end
    doc_hash
  end

  private

  def sanitizer
    @sanitizer ||= Sanitizer.new
  end

  def sanitize(text)
    return text if text.blank?

    sanitizer.sanitize(text, scrubber: TextScrubber.new)
  end

  def other_fields
    doc_keys&.index_with { |key| get_value key }
            &.compact
            &.transform_values(&:to_s)
  end

  def get_value(key)
    value = send key
    sanitize_field?(key) ? sanitize(value) : value
  end

  def sanitize_field?(key)
    do_not_sanitize_these_fields.exclude? key
  end

  def do_not_sanitize_these_fields
    [:url, :other_fields]
  end

  attr_reader :document
end
