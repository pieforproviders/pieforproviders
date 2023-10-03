# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::AttendanceBatches' do
  let!(:state) do
    create(:state)
  end
  # rubocop:disable RSpec/LetSetup
  let!(:state_time_rules) do
    [
      create(
        :state_time_rule,
        name: "Partial Day #{state.name}",
        state:,
        min_time: 60, # 1minute
        max_time: (4 * 3600) + (59 * 60) # 4 hours 59 minutes
      ),
      create(
        :state_time_rule,
        name: "Full Day #{state.name}",
        state:,
        min_time: 5 * 3600, # 5 hours
        max_time: (10 * 3600) # 10 hours
      ),
      create(
        :state_time_rule,
        name: "Full - Partial Day #{state.name}",
        state:,
        min_time: (10 * 3600) + 60, # 10 hours and 1 minute
        max_time: (24 * 3600)
      )
    ]
  end
  # rubocop:enable RSpec/LetSetup
  let!(:logged_in_user) { create(:confirmed_user, :nebraska) }
  let!(:business) { create(:business, :nebraska_ldds, user: logged_in_user) }
  let!(:child_business) { create(:child_business, business:) }
  let!(:approval) { create(:approval, num_children: 3, business:) }
  let!(:children) { approval.children }
  let!(:non_owner_child) { create(:necc_child) }
  let!(:first_check_in) { (approval.effective_on + 3.days + 12.hours + 33.minutes).strftime('%Y-%m-%d %I:%M%P') }
  let!(:first_check_out) { (approval.effective_on + 3.days + 17.hours + 18.minutes).strftime('%Y-%m-%d %I:%M%P') }
  let!(:second_check_in) { (approval.effective_on + 4.days + 8.hours + 11.minutes).strftime('%Y-%m-%d %I:%M%P') }
  let!(:second_check_out) { (approval.effective_on + 4.days + 14.hours + 29.minutes).strftime('%Y-%m-%d %I:%M%P') }

  children.each { |child| child_business.child = child }
  include_context 'with correct api version header'

  before do
    sign_in logged_in_user
    children.each(&:reload) # triggers changes as a result of the callbacks in the model
    non_owner_child.reload # triggers changes as a result of the callbacks in the model
  end

  describe 'POST /api/v1/attendance_batches' do
    let!(:effective_date) { children[0].schedules.first.effective_on }

    context 'when sent with an absence string' do
      context 'with a permitted absence type on the service day' do
        before { children[0].schedules.first.update!(expires_on: effective_date + 1.year) }

        let(:valid_absence_batch) do
          {
            attendance_batch:
            [
              {
                check_in: Helpers.prior_weekday(effective_date + 30.days, children[0].schedules.first.weekday).to_s,
                child_id: children[0].id,
                service_day_attributes: {
                  absence_type: 'absence'
                }
              },
              {
                check_in: Helpers.prior_weekday(effective_date + 15.days, children[0].schedules.first.weekday).to_s,
                child_id: children[0].id,
                service_day_attributes: {
                  absence_type: 'covid_absence'
                }
              }
            ]
          }
        end

        it 'creates service days and returns an empty array' do
          post('/api/v1/attendance_batches', params: valid_absence_batch, headers:)

          parsed_response = response.parsed_body
          expect(parsed_response['service_days'].pluck('attendances').flatten).to eq([])
          expect(parsed_response.dig('meta', 'errors')).to eq({})
          expect(Attendance.all.size).to eq(0)
          expect(ServiceDay.all.size).to eq(2)
          expect(response).to match_response_schema('attendance_batch')
        end

        it 'creates a service day with an absence_on_scheduled_day absence_type' do
          post('/api/v1/attendance_batches', params: valid_absence_batch, headers:)
          expect(ServiceDay.where(absence_type: 'absence_on_scheduled_day').size).to eq(1)
        end
      end

      context 'with a permitted absence type on the attendance' do
        let(:valid_absence_batch) do
          {
            attendance_batch:
            [
              {
                check_in: Helpers.prior_weekday(effective_date + 30.days, children[0].schedules.first.weekday).to_s,
                child_id: children[0].id,
                absence: 'absence'
              },
              {
                check_in: Helpers.prior_weekday(effective_date + 15.days, children[0].schedules.first.weekday).to_s,
                child_id: children[0].id,
                absence: 'covid_absence'
              }
            ]
          }
        end

        it 'creates service days and returns successful records' do
          post('/api/v1/attendance_batches', params: valid_absence_batch, headers:)

          parsed_response = response.parsed_body
          expect(parsed_response['service_days'].pluck('attendances').flatten).to eq([])
          expect(parsed_response.dig('meta', 'errors')).to eq({})
          expect(Attendance.all.size).to eq(0)
          expect(ServiceDay.all.size).to eq(2)
          expect(response).to match_response_schema('attendance_batch')
        end
      end

      context 'with a non-permitted absence type on one record on the service day' do
        let(:single_invalid_absence_batch) do
          {
            attendance_batch:
            [
              {
                check_in: Helpers.prior_weekday(effective_date + 30.days, children[0].schedules.first.weekday).to_s,
                child_id: children[0].id,
                service_day_attributes: {
                  absence_type: 'covid_absence'
                }
              },
              {
                check_in: Helpers.prior_weekday(effective_date + 15.days, children[0].schedules.first.weekday).to_s,
                child_id: children[0].id,
                service_day_attributes: {
                  absence_type: 'fake_reason'
                }
              }
            ]
          }
        end

        it 'returns json errors' do
          post('/api/v1/attendance_batches', params: single_invalid_absence_batch, headers:)

          parsed_response = response.parsed_body
          expect(parsed_response['service_days'].pluck('attendances').flatten).to eq([])
          expect(parsed_response.dig('meta', 'errors')).to be_present
          expect(parsed_response.dig('meta', 'errors').keys.flatten).to match_array(%w[service_day])
          expect(
            parsed_response.dig('meta', 'errors').values.flatten
          ).to contain_exactly('Validation failed: Absence type is not included in the list')
          expect(Attendance.all.size).to eq(0)
          expect(ServiceDay.all.size).to eq(1)
          expect(response).to match_response_schema('attendance_batch')
        end
      end

      context 'with a non-permitted absence type on one record on the attendance' do
        let(:single_invalid_absence_batch) do
          {
            attendance_batch:
            [
              {
                check_in: Helpers.prior_weekday(effective_date + 30.days, children[0].schedules.first.weekday).to_s,
                child_id: children[0].id,
                absence: 'covid_absence'
              },
              {
                check_in: Helpers.prior_weekday(effective_date + 15.days, children[0].schedules.first.weekday).to_s,
                child_id: children[0].id,
                absence: 'fake_reason'
              }
            ]
          }
        end

        it 'returns json errors' do
          post('/api/v1/attendance_batches', params: single_invalid_absence_batch, headers:)

          parsed_response = response.parsed_body
          expect(parsed_response['service_days'].pluck('attendances').flatten).to eq([])
          expect(parsed_response.dig('meta', 'errors')).to be_present
          expect(parsed_response.dig('meta', 'errors').keys.flatten).to match_array(%w[service_day])
          expect(
            parsed_response.dig('meta', 'errors').values.flatten
          ).to contain_exactly('Validation failed: Absence type is not included in the list')
          expect(Attendance.all.size).to eq(0)
          expect(ServiceDay.all.size).to eq(1)
          expect(response).to match_response_schema('attendance_batch')
        end
      end

      context 'with a non-permitted absence type on all records on the service day' do
        let(:all_invalid_absence_batch) do
          {
            attendance_batch:
            [
              {
                check_in: Helpers.prior_weekday(effective_date + 30.days, children[0].schedules.first.weekday).to_s,
                child_id: children[0].id,
                service_day_attributes: {
                  absence_type: 'fake_reason'
                }
              },
              {
                check_in: Helpers.prior_weekday(effective_date + 15.days, children[0].schedules.first.weekday).to_s,
                child_id: children[0].id,
                service_day_attributes: {
                  absence_type: 'fake_reason'
                }
              }
            ]
          }
        end

        it 'returns json errors' do
          post('/api/v1/attendance_batches', params: all_invalid_absence_batch, headers:)

          parsed_response = response.parsed_body
          expect(parsed_response['service_days'].pluck('attendances').flatten).to eq([])
          expect(parsed_response.dig('meta', 'errors')).to be_present
          expect(parsed_response.dig('meta', 'errors').keys.flatten).to match_array(%w[service_day])
          expect(
            parsed_response.dig('meta', 'errors').values.flatten
          ).to contain_exactly('Validation failed: Absence type is not included in the list',
                               'Validation failed: Absence type is not included in the list')
          expect(Attendance.all.size).to eq(0)
          expect(ServiceDay.all.size).to eq(0)
          expect(response).to match_response_schema('attendance_batch')
        end
      end

      context 'with a non-permitted absence type on all records on the attendance' do
        let(:all_invalid_absence_batch) do
          {
            attendance_batch:
            [
              {
                check_in: Helpers.prior_weekday(effective_date + 30.days, children[0].schedules.first.weekday).to_s,
                child_id: children[0].id,
                absence: 'fake_reason'
              },
              {
                check_in: Helpers.prior_weekday(effective_date + 15.days, children[0].schedules.first.weekday).to_s,
                child_id: children[0].id,
                absence: 'fake_reason'
              }
            ]
          }
        end

        it 'returns json errors' do
          post('/api/v1/attendance_batches', params: all_invalid_absence_batch, headers:)

          parsed_response = response.parsed_body
          expect(parsed_response['service_days'].pluck('attendances').flatten).to eq([])
          expect(parsed_response.dig('meta', 'errors')).to be_present
          expect(parsed_response.dig('meta', 'errors').keys.flatten).to match_array(%w[service_day])
          expect(
            parsed_response.dig('meta', 'errors').values.flatten
          ).to contain_exactly('Validation failed: Absence type is not included in the list',
                               'Validation failed: Absence type is not included in the list')
          expect(Attendance.all.size).to eq(0)
          expect(ServiceDay.all.size).to eq(0)
          expect(response).to match_response_schema('attendance_batch')
        end
      end

      context 'with an absence on a non-scheduled day on one record on the service day' do
        let(:single_non_scheduled_absence_batch) do
          {
            attendance_batch:
            [
              {
                check_in: Helpers.prior_weekday(effective_date + 30.days, children[0].schedules.first.weekday).to_s,
                child_id: children[0].id,
                service_day_attributes: {
                  absence_type: 'covid_absence'
                }
              },
              {
                # attendance on a Sunday, not a default scheduled day
                check_in: Helpers.prior_weekday(effective_date + 15.days, 0).to_s,
                child_id: children[0].id,
                service_day_attributes: {
                  absence_type: 'absence'
                }
              }
            ]
          }
        end

        it 'does not return json errors' do
          post('/api/v1/attendance_batches', params: single_non_scheduled_absence_batch, headers:)

          parsed_response = response.parsed_body
          expect(parsed_response['service_days'].pluck('attendances').flatten).to eq([])
          expect(parsed_response.dig('meta', 'errors')).not_to be_present
          expect(parsed_response.dig('meta', 'errors').keys.flatten).not_to match_array(%w[service_day])
          expect(
            parsed_response.dig('meta', 'errors').values.flatten
          ).not_to contain_exactly("Validation failed: Absence type can't create for a day without a schedule")
          expect(Attendance.all.size).to eq(0)
          expect(ServiceDay.all.size).to eq(2)
          expect(response).to match_response_schema('attendance_batch')
        end

        it 'generates a service day with an absence_on_unscheduled_day absence_type' do
          post('/api/v1/attendance_batches', params: single_non_scheduled_absence_batch, headers:)

          expect(ServiceDay.where(absence_type: 'absence_on_unscheduled_day').size).to eq(1)
        end
      end

      context 'with an absence on a non-scheduled day on one record on the attendance' do
        let(:single_non_scheduled_absence_batch) do
          {
            attendance_batch:
            [
              {
                check_in: Helpers.prior_weekday(effective_date + 30.days, children[0].schedules.first.weekday).to_s,
                child_id: children[0].id,
                absence: 'covid_absence'
              },
              {
                # attendance on a Sunday, not a default scheduled day
                check_in: Helpers.prior_weekday(effective_date + 15.days, 0).to_s,
                child_id: children[0].id,
                absence: 'absence'
              }
            ]
          }
        end

        it 'does not return json errors' do
          post('/api/v1/attendance_batches', params: single_non_scheduled_absence_batch, headers:)

          parsed_response = response.parsed_body
          expect(parsed_response['service_days'].pluck('attendances').flatten).to eq([])
          expect(parsed_response.dig('meta', 'errors')).not_to be_present
          expect(parsed_response.dig('meta', 'errors').keys.flatten).not_to match_array(%w[service_day])
          expect(
            parsed_response.dig('meta', 'errors').values.flatten
          ).not_to contain_exactly("Validation failed: Absence type can't create for a day without a schedule")
          expect(Attendance.all.size).to eq(0)
          expect(ServiceDay.all.size).to eq(2)
          expect(response).to match_response_schema('attendance_batch')
        end
      end

      context 'with an absence on a non-scheduled day on all records on the service day' do
        let(:all_non_scheduled_absence_batch) do
          {
            attendance_batch:
            [
              {
                # attendance on a Sunday, not a default scheduled day
                check_in: Helpers.prior_weekday(effective_date + 30.days, 0).to_s,
                child_id: children[0].id,
                service_day_attributes: {
                  absence_type: 'covid_absence'
                }
              },
              {
                # attendance on a Sunday, not a default scheduled day
                check_in: Helpers.prior_weekday(effective_date + 15.days, 0).to_s,
                child_id: children[0].id,
                service_day_attributes: {
                  absence_type: 'absence'
                }
              }
            ]
          }
        end

        it 'does not return json errors' do
          post('/api/v1/attendance_batches', params: all_non_scheduled_absence_batch, headers:)

          parsed_response = response.parsed_body
          expect(parsed_response['service_days'].pluck('attendances').flatten).to eq([])
          expect(parsed_response.dig('meta', 'errors')).not_to be_present
          expect(parsed_response.dig('meta', 'errors').keys.flatten).not_to match_array(%w[service_day])
          expect(
            parsed_response.dig('meta', 'errors').values.flatten
          ).not_to contain_exactly("Validation failed: Absence type can't create for a day without a schedule",
                                   "Validation failed: Absence type can't create for a day without a schedule")
          expect(Attendance.all.size).to eq(0)
          expect(ServiceDay.all.size).to eq(2)
          expect(response).to match_response_schema('attendance_batch')
        end
      end

      context 'with an absence on a non-scheduled day on all records on the attendance' do
        let(:all_non_scheduled_absence_batch) do
          {
            attendance_batch:
            [
              {
                # attendance on a Sunday, not a default scheduled day
                check_in: Helpers.prior_weekday(effective_date + 30.days, 0).to_s,
                child_id: children[0].id,
                absence: 'covid_absence'
              },
              {
                # attendance on a Sunday, not a default scheduled day
                check_in: Helpers.prior_weekday(effective_date + 15.days, 0).to_s,
                child_id: children[0].id,
                absence: 'absence'
              }
            ]
          }
        end

        it 'does not return json errors' do
          post('/api/v1/attendance_batches', params: all_non_scheduled_absence_batch, headers:)

          parsed_response = response.parsed_body
          expect(parsed_response['service_days'].pluck('attendances').flatten).to eq([])
          expect(parsed_response.dig('meta', 'errors')).not_to be_present
          expect(parsed_response.dig('meta', 'errors').keys.flatten).not_to match_array(%w[service_day])
          expect(
            parsed_response.dig('meta', 'errors').values.flatten
          ).not_to contain_exactly("Validation failed: Absence type can't create for a day without a schedule",
                                   "Validation failed: Absence type can't create for a day without a schedule")
          expect(Attendance.all.size).to eq(0)
          expect(ServiceDay.all.size).to eq(2)
          expect(response).to match_response_schema('attendance_batch')
        end
      end
    end

    context 'when sent with all required fields' do
      let(:valid_batch) do
        {
          attendance_batch:
          [
            {
              check_in: first_check_in,
              check_out: first_check_out,
              child_id: children[0].id
            },
            {
              check_in: second_check_in,
              check_out: second_check_out,
              child_id: children[0].id
            }
          ]
        }
      end

      context 'when the child has no active approval for that time period' do
        it 'returns an error' do
          children[0].approvals.first.update!(expires_on: '2021-02-01')
          children[0].approvals.first.reload
          post('/api/v1/attendance_batches', params: valid_batch, headers:)

          parsed_response = response.parsed_body
          expect(parsed_response.dig('meta', 'errors')).to be_present
          expect(parsed_response.dig('meta', 'errors').keys.flatten).to eq(['child_approval_id'])
          expect(parsed_response.dig('meta', 'errors').values.flatten[0])
            .to include('has no active approval for attendance date')
          expect(response).to match_response_schema('attendance_batch')
        end
      end

      it 'creates attendances and returns successful records' do
        post('/api/v1/attendance_batches', params: valid_batch, headers:)

        parsed_response = response.parsed_body
        first_parsed_response_object, second_parsed_response_object = parsed_response['service_days']
        first_input_object, second_input_object = valid_batch[:attendance_batch]

        expect(DateTime.parse(first_parsed_response_object['attendances'].first['check_in']))
          .to be_within(1.second)
          .of(DateTime.parse(first_input_object[:check_in]))
        expect(DateTime.parse(first_parsed_response_object['attendances'].first['check_out']))
          .to be_within(1.second)
          .of(DateTime.parse(first_input_object[:check_out]))
        expect(first_parsed_response_object['attendances'].first['child_approval_id'])
          .to eq(
            Child.find(first_input_object[:child_id])
              .active_child_approval(Date.parse(first_input_object[:check_in])).id
          )

        expect(DateTime.parse(second_parsed_response_object['attendances'].first['check_in']))
          .to be_within(1.second)
          .of(DateTime.parse(second_input_object[:check_in]))
        expect(DateTime.parse(second_parsed_response_object['attendances'].first['check_out']))
          .to be_within(1.second)
          .of(DateTime.parse(second_input_object[:check_out]))
        expect(second_parsed_response_object['attendances'].first['child_approval_id'])
          .to eq(
            Child.find(second_input_object[:child_id])
              .active_child_approval(Date.parse(second_input_object[:check_in])).id
          )

        expect(response).to match_response_schema('attendance_batch')
      end
    end

    context 'when missing required fields on one record' do
      let(:batch_with_one_invalid_record) do
        {
          attendance_batch:
          [
            {
              check_in: first_check_in,
              check_out: first_check_out,
              child_id: children[0].id
            },
            {
              check_in: second_check_in,
              check_out: second_check_out
            }
          ]
        }
      end

      it 'returns json errors' do
        post('/api/v1/attendance_batches', params: batch_with_one_invalid_record, headers:)

        parsed_response = response.parsed_body
        first_parsed_response_object, = parsed_response['service_days']
        first_input_object, = batch_with_one_invalid_record[:attendance_batch]

        expect(DateTime.parse(first_parsed_response_object['attendances'].first['check_in']))
          .to be_within(1.second)
          .of(DateTime.parse(first_input_object[:check_in]))
        expect(DateTime.parse(first_parsed_response_object['attendances'].first['check_out']))
          .to be_within(1.second)
          .of(DateTime.parse(first_input_object[:check_out]))
        expect(first_parsed_response_object['attendances'].first['child_approval_id'])
          .to eq(
            Child.find(first_input_object[:child_id])
              .active_child_approval(Date.parse(first_input_object[:check_in])).id
          )

        expect(parsed_response.dig('meta', 'errors')).to be_present
        expect(parsed_response.dig('meta', 'errors').keys.flatten).to eq(['child_id'])
        expect(parsed_response.dig('meta', 'errors').values.flatten[0]).to eq("can't be blank")
        expect(response).to match_response_schema('attendance_batch')
      end
    end

    context 'when missing required fields on all records' do
      let(:batch_with_all_invalid_records) do
        {
          attendance_batch:
          [
            {
              check_in: first_check_in,
              check_out: first_check_out
            },
            {
              check_in: second_check_in,
              check_out: second_check_out
            }
          ]
        }
      end

      it 'returns json errors' do
        post('/api/v1/attendance_batches', params: batch_with_all_invalid_records, headers:)

        parsed_response = response.parsed_body

        expect(parsed_response.dig('meta', 'errors')).to be_present
        expect(parsed_response.dig('meta', 'errors').keys.flatten).to eq(%w[child_id])
        expect(parsed_response.dig('meta', 'errors').values.flatten[0]).to eq("can't be blank")
        expect(response).to match_response_schema('attendance_batch')
      end
    end

    context "when adding an attendance for a child not in the user's care" do
      let(:batch_with_child_not_in_care) do
        {
          attendance_batch:
          [
            {
              check_in: first_check_in,
              check_out: first_check_out,
              child_id: children[0].id
            },
            {
              check_in: second_check_in,
              check_out: second_check_out,
              child_id: non_owner_child.id
            }
          ]
        }
      end

      it 'returns json errors' do
        post('/api/v1/attendance_batches', params: batch_with_child_not_in_care, headers:)

        parsed_response = response.parsed_body
        first_parsed_response_object, = parsed_response['service_days']
        first_input_object, = batch_with_child_not_in_care[:attendance_batch]

        expect(DateTime.parse(first_parsed_response_object['attendances'].first['check_in']))
          .to be_within(1.second)
          .of(DateTime.parse(first_input_object[:check_in]))
        expect(DateTime.parse(first_parsed_response_object['attendances'].first['check_out']))
          .to be_within(1.second)
          .of(DateTime.parse(first_input_object[:check_out]))
        expect(first_parsed_response_object['attendances'].first['child_approval_id'])
          .to eq(
            Child.find(first_input_object[:child_id])
              .active_child_approval(Date.parse(first_input_object[:check_in])).id
          )

        expect(parsed_response.dig('meta', 'errors')).to be_present
        expect(parsed_response.dig('meta', 'errors').keys.flatten).to eq(['child_id'])
        expect(parsed_response.dig('meta', 'errors').values.flatten[0])
          .to eq("not allowed to create an attendance for child #{non_owner_child.id}")
        expect(response).to match_response_schema('attendance_batch')
      end
    end
  end
end
