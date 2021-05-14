# frozen_string_literal: true

require 'rails_helper' # TODO why?

    # Imitating the tests from DashboardProcessor
RSpec.describe NebraskaRatesImporter do
  let!(:dashboard_csv) { Rails.root.join('spec/fixtures/files/nebrask_rates.csv') }
  let!(:invalid_csv) { Rails.root.join('spec/fixtures/files/invalid_format.csv') }
  # let!(:missing_field_csv)

  # why are separate tests with string instead of file inputs necessary?
  # let!(:valid_string) do
  #   <<~CSV
  #     ...snipped...
  #   CSV
  # end

  #test 1: it reads the file and sees the correct content.

  #test 2: it aborts on a bad file

  #test 3: it persists rates if the inputs are all good

  #test 4: it persists nothing if any of the inputs are bad

  # what does input mean in this? described_class.new(input).call
  # how to expect a logged error?: TODO
  # if I need to define any instance variables, use let like this:
  #   let!(:business) { create(:business, name: 'Test Day Care') }
  #   let!(:first_child) { create(:necc_child, full_name: 'Sarah Brighton', business: business) }
  #   let(:error_log) do
  #     ...

  RSpec.shared_examples 'updates sarah' do
    it "sets sarah's attributes correctly" do
      described_class.new(input).call
      expect(first_child.temporary_nebraska_dashboard_case.as_of).to eq('2021-02-21')
    end
  end

  RSpec.shared_examples 'creates records, attributes, does not stop job on failure to find child' do
    it 'creates dashboard records for every row in the file, idempotently' do
      expect { described_class.new(input).call }.to change { TemporaryNebraskaDashboardCase.count }.from(0).to(3)
      expect { described_class.new(input).call }.not_to change(TemporaryNebraskaDashboardCase, :count)
    end

    include_examples 'updates sarah'
  end

  describe '.call' do
    before do
      allow(Rails.application.config).to receive(:aws_necc_dashboard_archive_bucket).and_return(archive_bucket)
      allow(Aws::S3::Client).to receive(:new) { stubbed_client }
    end

    context 'with a valid string' do
      let(:input) { valid_string }
      include_examples 'creates records, attributes, does not stop job on failure to find child'
    end

    context 'with a valid file' do
      let(:input) { dashboard_csv }
      include_examples 'creates records, attributes, does not stop job on failure to find child'
    end

    context 'when the csv data is the wrong format' do
      let(:error_log) { [[%w[wrong_headers nope], %w[icon yep], %w[face maybe]]].flatten.to_s }

      context 'from a file' do
        let(:invalid_input) { invalid_csv }
        include_examples 'invalid input returns false'
      end
    end
  end
end
