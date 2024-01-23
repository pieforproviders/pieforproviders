# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/PendingWithoutReason
# rubocop:disable FactoryBot/ExcessiveCreateList
RSpec.xdescribe 'Api::V1::Users', type: :request do
  include_context 'with correct api version header'
  include_context 'when authenticated as an admin'
  # let!(:nebraska_business) do
  #   create(:business, :nebraska_ldds, user: create(:confirmed_user, :nebraska))
  # end

  before do
    start_time = Time.current
    puts "Started Seeding: #{start_time}"
    if Rails.application.config.performance_testing
      tables_to_import = [
        NebraskaRate,
        User,
        Business,
        Approval,
        Child,
        ChildApproval,
        Schedule,
        ServiceDay,
        Attendance,
        NebraskaApprovalAmount
      ]
      tables_to_import.each do |klass|
        # file = Rails.root.join("spec/fixtures/files/prod_like_seeds/#{klass.model_name.plural}.json")
        # klass.insert_all(JSON.parse(file.read)) if file
      end
    else
      create_list(:attendance, 10)
    end
    puts "Seed Time: #{(Time.current - start_time).seconds} seconds"
  end

  it 'performs under 3s' do
    puts "Started the test: #{Time.current}"
    expect { get '/api/v1/case_list_for_dashboard', headers: }.to perform_under(3).sec
  end
end
# rubocop:enable RSpec/PendingWithoutReason
# rubocop:enable FactoryBot/ExcessiveCreateList
