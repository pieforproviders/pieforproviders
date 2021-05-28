# frozen_string_literal: true

# Service to extract locale from the `Accept-Language` header
class LocaleExtractor < ApplicationService
  def initialize(accept_lang_header)
    @header = accept_lang_header
  end

  def extract
    matches = locales & I18n.available_locales.map(&:to_s)
    matches[0] || I18n.default_locale.to_s
  end

  private

  attr_accessor :header

  def locales
    # 1. Strip quality values
    # Ref: https://developer.mozilla.org/en-US/docs/Glossary/Quality_values
    # 2. Strip region variants from the language tags ('es-MX' => 'es')
    header
      .gsub(/;q=\d.\d{1,3}/, '')
      .split(',')
      .map { |tag| tag.split('-')[0] }
  end
end
