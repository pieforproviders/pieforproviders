# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LocaleExtractor do
  context 'with an empty header' do
    it 'returns "en"' do
      locale = described_class.new('').extract
      expect(locale).to eq('en')
    end
  end

  context 'with a wildcard header' do
    it 'returns "en"' do
      locale = described_class.new('*').extract
      expect(locale).to eq('en')
    end
  end

  context 'with an unavailable locale' do
    it 'returns "en"' do
      locale = described_class.new('fr').extract
      expect(locale).to eq('en')
    end
  end

  context 'with a header without quality values' do
    it 'returns the user\'s preferred locale' do
      locale = described_class.new('es-MX,en,fr').extract
      expect(locale).to eq('es')

      locale = described_class.new('en-US,es').extract
      expect(locale).to eq('en')
    end
  end

  context 'with a header with quality values' do
    it 'returns the user\'s preferred locale' do
      locale = described_class.new('es-CO,es;q=0.5').extract
      expect(locale).to eq('es')

      locale = described_class.new('de-CH,de;q=0.7,ja;q=0.3').extract
      expect(locale).to eq('en')
    end
  end
end
