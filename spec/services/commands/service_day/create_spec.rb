# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Commands::ServiceDay::Create, type: :service do
  let(:child) { create(:necc_child) }
  let(:date) { Time.current }

  describe '#initialize' do
    it 'initializes with required info' do
      expect do
        described_class.new(child: child, date: date.at_beginning_of_day)
      end.to not_raise_error
    end

    it 'throws an error when missing required info' do
      expect do
        described_class.new(child: child)
      end.to raise_error(ArgumentError)
    end
  end

  describe '#create' do
    it 'creates a service day for the given date and child' do
      service_day = described_class.new(child: child, date: date.at_beginning_of_day).create
      expect(service_day.date).to eq(date.at_beginning_of_day)
    end
  end
end
