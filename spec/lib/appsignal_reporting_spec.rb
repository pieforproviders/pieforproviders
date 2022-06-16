# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AppsignalReporting do
  let!(:included_class) { Class.new { include AppsignalReporting } }
  let!(:stubbed_appsignal) { double('Appsignal') }

  before do
    stub_const('Appsignal', stubbed_appsignal)
    allow(stubbed_appsignal).to receive(:send_error)
  end

  describe '#send_error' do
    it "calls stubbed_appsignal's #send_error method with required fields" do
      included_class.new.send_appsignal_error(
        action: 'action',
        exception: StandardError,
        metadata: { identifier: 'identifier' }
      )
      expect(stubbed_appsignal).to have_received(:send_error).with(StandardError)
    end
  end
end
