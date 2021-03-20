# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RateAssociatorJob, type: :job do
  describe '#perform' do
    let(:child) { create(:child) }
    let(:service) { instance_double(RateAssociator) }

    before { allow(RateAssociator).to receive(:new).and_return(service) }

    it 'queues the job' do
      expect { described_class.perform_later(child.id) }.to have_enqueued_job(described_class).with(child.id)
    end

    context 'when the job is performed' do
      it 'calls the subsidy rule associator' do
        expect(service).to receive(:call).and_return(true)
        described_class.perform_now(child.id)
      end
    end
  end
end
