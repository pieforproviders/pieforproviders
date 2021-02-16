# frozen_string_literal: true

require 'rails_helper'

module Wonderschool
  module Necc
    RSpec.describe DashboardProcessor do
      let!(:dashboard_csv) { Rails.root.join('spec/fixtures/files/wonderschool_necc_dashboard_data.csv') }
      let!(:invalid_csv) { Rails.root.join('spec/fixtures/files/wonderschool_necc_dashboard_data_invalid_format.csv') }
      let!(:valid_string) do
        'child_full_name,absences,attendance_risk,earned_revenue,estimated_revenue,'\
        "full_days,hours,transportation_revenue\nSarah Brighton,3 of 10,on_track,"\
        "1235.48,2353.23,10 of 18,3 of 8,33 trips - $212.50\nCharles Williamson,1 of 10,at_risk,"\
        "98.21,1234.56,1 of 15,1 of 18,2 trips - $22.00\nAdédèjì Adébísí,11 of 10,exceeded_limit,"\
        '330.00,330.00,3 of 15,4 of 18,N/A'
      end
      let!(:first_child) { create(:necc_child, full_name: 'Sarah Brighton') }
      let!(:second_child) { create(:necc_child, full_name: 'Charles Williamson') }
      let!(:third_child) { create(:necc_child, full_name: 'Adédèjì Adébísí') }

      describe '.call' do
        context "when a file name passed in doesn't exist" do
          it 'returns false' do
            expect(described_class.new(Rails.root.join('fake.csv')).call).to eq(false)
          end
        end

        context 'with a valid string' do
          it 'creates dashboard records for every row in the file, idempotently' do
            expect { described_class.new(valid_string).call }.to change { TemporaryNebraskaDashboardCase.count }.from(0).to(3)
            expect { described_class.new(valid_string).call }.not_to change(TemporaryNebraskaDashboardCase, :count)
          end

          it 'creates dashboard records for the correct child with the correct data' do
            described_class.new(valid_string).call
            expect(first_child.temporary_nebraska_dashboard_case.absences).to eq('3 of 10')
            expect(second_child.temporary_nebraska_dashboard_case.absences).to eq('1 of 10')
            expect(third_child.temporary_nebraska_dashboard_case.absences).to eq('11 of 10')
            expect(first_child.temporary_nebraska_dashboard_case.attendance_risk).to eq('on_track')
            expect(second_child.temporary_nebraska_dashboard_case.attendance_risk).to eq('at_risk')
            expect(third_child.temporary_nebraska_dashboard_case.attendance_risk).to eq('exceeded_limit')
            expect(first_child.temporary_nebraska_dashboard_case.earned_revenue).to eq('1235.48')
            expect(second_child.temporary_nebraska_dashboard_case.earned_revenue).to eq('98.21')
            expect(third_child.temporary_nebraska_dashboard_case.earned_revenue).to eq('330.00')
            expect(first_child.temporary_nebraska_dashboard_case.estimated_revenue).to eq('2353.23')
            expect(second_child.temporary_nebraska_dashboard_case.estimated_revenue).to eq('1234.56')
            expect(third_child.temporary_nebraska_dashboard_case.estimated_revenue).to eq('330.00')
            expect(first_child.temporary_nebraska_dashboard_case.full_days).to eq('10 of 18')
            expect(second_child.temporary_nebraska_dashboard_case.full_days).to eq('1 of 15')
            expect(third_child.temporary_nebraska_dashboard_case.full_days).to eq('3 of 15')
            expect(first_child.temporary_nebraska_dashboard_case.hours).to eq('3 of 8')
            expect(second_child.temporary_nebraska_dashboard_case.hours).to eq('1 of 18')
            expect(third_child.temporary_nebraska_dashboard_case.hours).to eq('4 of 18')
            expect(first_child.temporary_nebraska_dashboard_case.transportation_revenue).to eq('33 trips - $212.50')
            expect(second_child.temporary_nebraska_dashboard_case.transportation_revenue).to eq('2 trips - $22.00')
            expect(third_child.temporary_nebraska_dashboard_case.transportation_revenue).to eq('N/A')
          end

          it "does not stop the job if the child doesn't exist, and logs the failed child" do
            first_child.destroy!
            expect(Rails.logger).to receive(:tagged).and_yield
            expect(Rails.logger).to receive(:error).with([
                                                           [
                                                             ['child_full_name', 'Sarah Brighton'],
                                                             ['absences', '3 of 10'],
                                                             %w[attendance_risk on_track],
                                                             ['earned_revenue', '1235.48'],
                                                             ['estimated_revenue', '2353.23'],
                                                             ['full_days', '10 of 18'],
                                                             ['hours', '3 of 8'],
                                                             ['transportation_revenue', '33 trips - $212.50']
                                                           ]
                                                         ])
            described_class.new(valid_string).call
          end
        end

        context 'with a valid stream' do
          it 'creates dashboard records for every row in the file, idempotently' do
            expect { described_class.new(StringIO.new(valid_string)).call }.to change { TemporaryNebraskaDashboardCase.count }.from(0).to(3)
            expect { described_class.new(StringIO.new(valid_string)).call }.not_to change(TemporaryNebraskaDashboardCase, :count)
          end

          it 'creates dashboard records for the correct child with the correct data' do
            described_class.new(StringIO.new(valid_string)).call
            expect(first_child.temporary_nebraska_dashboard_case.absences).to eq('3 of 10')
            expect(second_child.temporary_nebraska_dashboard_case.absences).to eq('1 of 10')
            expect(third_child.temporary_nebraska_dashboard_case.absences).to eq('11 of 10')
            expect(first_child.temporary_nebraska_dashboard_case.attendance_risk).to eq('on_track')
            expect(second_child.temporary_nebraska_dashboard_case.attendance_risk).to eq('at_risk')
            expect(third_child.temporary_nebraska_dashboard_case.attendance_risk).to eq('exceeded_limit')
            expect(first_child.temporary_nebraska_dashboard_case.earned_revenue).to eq('1235.48')
            expect(second_child.temporary_nebraska_dashboard_case.earned_revenue).to eq('98.21')
            expect(third_child.temporary_nebraska_dashboard_case.earned_revenue).to eq('330.00')
            expect(first_child.temporary_nebraska_dashboard_case.estimated_revenue).to eq('2353.23')
            expect(second_child.temporary_nebraska_dashboard_case.estimated_revenue).to eq('1234.56')
            expect(third_child.temporary_nebraska_dashboard_case.estimated_revenue).to eq('330.00')
            expect(first_child.temporary_nebraska_dashboard_case.full_days).to eq('10 of 18')
            expect(second_child.temporary_nebraska_dashboard_case.full_days).to eq('1 of 15')
            expect(third_child.temporary_nebraska_dashboard_case.full_days).to eq('3 of 15')
            expect(first_child.temporary_nebraska_dashboard_case.hours).to eq('3 of 8')
            expect(second_child.temporary_nebraska_dashboard_case.hours).to eq('1 of 18')
            expect(third_child.temporary_nebraska_dashboard_case.hours).to eq('4 of 18')
            expect(first_child.temporary_nebraska_dashboard_case.transportation_revenue).to eq('33 trips - $212.50')
            expect(second_child.temporary_nebraska_dashboard_case.transportation_revenue).to eq('2 trips - $22.00')
            expect(third_child.temporary_nebraska_dashboard_case.transportation_revenue).to eq('N/A')
          end

          it "does not stop the job if the child doesn't exist, and logs the failed child" do
            first_child.destroy!
            expect(Rails.logger).to receive(:tagged).and_yield
            expect(Rails.logger).to receive(:error).with([
                                                           [
                                                             ['child_full_name', 'Sarah Brighton'],
                                                             ['absences', '3 of 10'],
                                                             %w[attendance_risk on_track],
                                                             ['earned_revenue', '1235.48'],
                                                             ['estimated_revenue', '2353.23'],
                                                             ['full_days', '10 of 18'],
                                                             ['hours', '3 of 8'],
                                                             ['transportation_revenue', '33 trips - $212.50']
                                                           ]
                                                         ])
            described_class.new(StringIO.new(valid_string)).call
          end
        end

        context 'with a valid file' do
          it 'creates dashboard records for every row in the file, idempotently' do
            expect { described_class.new(dashboard_csv).call }.to change { TemporaryNebraskaDashboardCase.count }.from(0).to(3)
            expect { described_class.new(dashboard_csv).call }.not_to change(TemporaryNebraskaDashboardCase, :count)
          end

          it 'creates dashboard records for the correct child with the correct data' do
            described_class.new(dashboard_csv).call
            expect(first_child.temporary_nebraska_dashboard_case.absences).to eq('3 of 10')
            expect(second_child.temporary_nebraska_dashboard_case.absences).to eq('1 of 10')
            expect(third_child.temporary_nebraska_dashboard_case.absences).to eq('11 of 10')
            expect(first_child.temporary_nebraska_dashboard_case.attendance_risk).to eq('on_track')
            expect(second_child.temporary_nebraska_dashboard_case.attendance_risk).to eq('at_risk')
            expect(third_child.temporary_nebraska_dashboard_case.attendance_risk).to eq('exceeded_limit')
            expect(first_child.temporary_nebraska_dashboard_case.earned_revenue).to eq('1235.48')
            expect(second_child.temporary_nebraska_dashboard_case.earned_revenue).to eq('98.21')
            expect(third_child.temporary_nebraska_dashboard_case.earned_revenue).to eq('330.00')
            expect(first_child.temporary_nebraska_dashboard_case.estimated_revenue).to eq('2353.23')
            expect(second_child.temporary_nebraska_dashboard_case.estimated_revenue).to eq('1234.56')
            expect(third_child.temporary_nebraska_dashboard_case.estimated_revenue).to eq('330.00')
            expect(first_child.temporary_nebraska_dashboard_case.full_days).to eq('10 of 18')
            expect(second_child.temporary_nebraska_dashboard_case.full_days).to eq('1 of 15')
            expect(third_child.temporary_nebraska_dashboard_case.full_days).to eq('3 of 15')
            expect(first_child.temporary_nebraska_dashboard_case.hours).to eq('3 of 8')
            expect(second_child.temporary_nebraska_dashboard_case.hours).to eq('1 of 18')
            expect(third_child.temporary_nebraska_dashboard_case.hours).to eq('4 of 18')
            expect(first_child.temporary_nebraska_dashboard_case.transportation_revenue).to eq('33 trips - $212.50')
            expect(second_child.temporary_nebraska_dashboard_case.transportation_revenue).to eq('2 trips - $22.00')
            expect(third_child.temporary_nebraska_dashboard_case.transportation_revenue).to eq('N/A')
          end

          it "does not stop the job if the child doesn't exist, and logs the failed child" do
            first_child.destroy!
            expect(Rails.logger).to receive(:tagged).and_yield
            expect(Rails.logger).to receive(:error).with([
                                                           [
                                                             ['child_full_name', 'Sarah Brighton'],
                                                             ['absences', '3 of 10'],
                                                             %w[attendance_risk on_track],
                                                             ['earned_revenue', '1235.48'],
                                                             ['estimated_revenue', '2353.23'],
                                                             ['full_days', '10 of 18'],
                                                             ['hours', '3 of 8'],
                                                             ['transportation_revenue', '33 trips - $212.50']
                                                           ]
                                                         ])
            described_class.new(dashboard_csv).call
          end
        end
        context 'when the csv data is the wrong format from a file' do
          it 'returns false' do
            expect(Rails.logger).to receive(:tagged).and_yield
            expect(Rails.logger).to receive(:error).with([[%w[wrong_headers nope], %w[icon yep], %w[face maybe]]])
            expect(described_class.new(invalid_csv).call).to eq(false)
          end
        end
        context 'when the csv data is the wrong format from a string' do
          it 'returns false' do
            expect(Rails.logger).to receive(:tagged).and_yield
            expect(Rails.logger).to receive(:error).with([[%w[wrong_headers nope], %w[icon yep], %w[face maybe]]])
            expect(described_class.new("wrong_headers,icon,face\nnope,yep,maybe").call).to eq(false)
          end
        end
        context 'when the csv data is the wrong format from a stream' do
          it 'returns false' do
            expect(Rails.logger).to receive(:tagged).and_yield
            expect(Rails.logger).to receive(:error).with([[%w[wrong_headers nope], %w[icon yep], %w[face maybe]]])
            expect(described_class.new(StringIO.new("wrong_headers,icon,face\nnope,yep,maybe")).call).to eq(false)
          end
        end
      end
    end
  end
end
