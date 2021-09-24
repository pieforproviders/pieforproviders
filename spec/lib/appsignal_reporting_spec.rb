# frozen_string_literal: true

require 'rails_helper'

RSpec.xdescribe AppsignalReporting do
  let!(:included_class) { Class.new { include AppsignalReporting } }
  let!(:stubbed_appsignal) { double('Appsignal') }
  let!(:exception) { double('StandardError') }
  let!(:identifier) { 'identifier' }

  describe '#send_error' do
    it "calls Appsignal's #send_error method with an exception and an identifier" do
      included_class.new.send_appsignal_error(exception, identifier)
      expect(stubbed_appsignal).to have_received(:send_error).with(exception).and_yield
    end
  end
end
