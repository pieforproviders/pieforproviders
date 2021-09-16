# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RateAssociatorJob, type: :job do
  describe '#perform' do
    let(:child) { create(:child) }
    let(:service) { instance_double(RateAssociator, call: true) }

    before { allow(RateAssociator).to receive(:new).and_return(service) }

    it 'queues the job with a valid id' do
      expect { described_class.perform_later(child.id) }.to have_enqueued_job(described_class).with(child.id)
      expect { described_class.perform_later('notanid') }.to have_enqueued_job(described_class).with('notanid')
    end

    context 'when the job is performed' do
      it 'calls the subsidy rule associator with a valid child id' do
        allow(service).to receive(:call).and_return(true)
        expect(described_class.perform_now(child.id)).to eq(true)
        expect(service).to have_received(:call)
      end

      it 'calls the subsidy rule associator with a valid child id and raises an error if the associator does' do
        allow(service).to receive(:call).and_raise(StandardError)
        expect { described_class.perform_now(child.id) }.to raise_error(StandardError)
        expect(service).to have_received(:call)
      end

      it 'does not call the subsidy rule associator with an invalid child id' do
        expect(described_class.perform_now('notanid')).to eq(nil)
        expect(service).not_to have_received(:call)
      end
    end
  end
end
