# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::AttendanceBatches', type: :request do
  let(:logged_in_user) { create(:confirmed_user) }
  let(:business) { create(:business, user: logged_in_user) }
  let(:children) { create_list(:child, 3, business: business) }

  describe 'POST /api/v1/attendance_batches' do
    include_context 'correct api version header'

    before do
      sign_in logged_in_user
    end

    context "when sent with an absence string" do
      context "with a permitted absence type" do
        let(:valid_absence_batch) do
          {
            attendance_batch:
            [
              {
                check_in: '2021/03/25 12:33pm',
                absence: 'absence',
                child_id: children[0].id
              },
              {
                check_in: '2021/03/28 8:12am',
                absence: 'covid_absence',
                child_id: children[0].id
              }
            ]
          }
        end

        it 'creates attendances and returns successful records' do
          post '/api/v1/attendance_batches', params: valid_absence_batch, headers: headers
  
          parsed_response = JSON.parse(response.body)
          first_parsed_response_object, second_parsed_response_object = parsed_response['attendances']
          first_input_object, second_input_object = valid_absence_batch[:attendance_batch]
  
          expect(DateTime.parse(first_parsed_response_object['check_in']))
            .to be_within(1.second)
            .of(DateTime.parse(first_input_object[:check_in]))
          expect(first_parsed_response_object['absence']).to eq(first_input_object[:absence])
          expect(first_parsed_response_object['child_approval_id'])
            .to eq(
              Child.find(first_input_object[:child_id])
                .active_child_approval(Date.parse(first_input_object[:check_in])).id
            )
  
          expect(DateTime.parse(second_parsed_response_object['check_in']))
            .to be_within(1.second)
            .of(DateTime.parse(second_input_object[:check_in]))
          expect(second_parsed_response_object['absence']).to eq(second_input_object[:absence])
          expect(second_parsed_response_object['child_approval_id'])
            .to eq(
              Child.find(second_input_object[:child_id])
                .active_child_approval(Date.parse(second_input_object[:check_in])).id
            )
  
          expect(response).to match_response_schema('attendance_batch')
        end
      end

      context "with a non-permitted absence type on one record" do
        let(:single_invalid_absence_batch) do
          {
            attendance_batch:
            [
              {
                check_in: '2021/03/25 12:33pm',
                absence: 'covid_absence',
                child_id: children[0].id
              },
              {
                check_in: '2021/03/28 8:12am',
                absence: 'fake_reason',
                child_id: children[0].id
              }
            ]
          }
        end

        it 'returns json errors' do
          post '/api/v1/attendance_batches', params: single_invalid_absence_batch, headers: headers
  
          parsed_response = JSON.parse(response.body)
          first_parsed_response_object, = parsed_response['attendances']
          first_input_object, = single_invalid_absence_batch[:attendance_batch]
  
          expect(DateTime.parse(first_parsed_response_object['check_in']))
            .to be_within(1.second)
            .of(DateTime.parse(first_input_object[:check_in]))
          expect(first_parsed_response_object['absence']).to eq(first_input_object[:absence])
          expect(first_parsed_response_object['child_approval_id'])
            .to eq(
              Child.find(first_input_object[:child_id])
                .active_child_approval(Date.parse(first_input_object[:check_in])).id
            )
  
          expect(parsed_response['meta']['errors']).to be_present
          expect(parsed_response['meta']['errors'].map(&:keys).flatten).to eq(['absence'])
          expect(parsed_response['meta']['errors'].map(&:values).flatten).to eq(["is invalid type"])
          expect(response).to match_response_schema('attendance_batch')
        end
      end
      
      context "with a non-permitted absence type on all records" do
        let(:all_invalid_absence_batch) do
          {
            attendance_batch:
            [
              {
                check_in: '2021/03/25 12:33pm',
                absence: 'covid_absence',
                child_id: children[0].id
              },
              {
                check_in: '2021/03/28 8:12am',
                absence: 'fake_reason',
                child_id: children[0].id
              }
            ]
          }
        end

        it 'returns json errors' do
          post '/api/v1/attendance_batches', params: all_invalid_absence_batch, headers: headers
  
          parsed_response = JSON.parse(response.body)
  
          expect(parsed_response['meta']['errors']).to be_present
          expect(parsed_response['meta']['errors'].map(&:keys).flatten).to eq(%w[absence absence])
          expect(parsed_response['meta']['errors'].map(&:values).flatten).to eq(["is invalid type", "is invalid type"])
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
              check_in: '2021/03/25 12:33pm',
              check_out: '2021/03/25 5:16pm',
              child_id: children[0].id
            },
            {
              check_in: '2021/03/28 8:12am',
              check_out: '2021/03/28 11:48am',
              child_id: children[0].id
            }
          ]
        }
      end

      it 'creates attendances and returns successful records' do
        post '/api/v1/attendance_batches', params: valid_batch, headers: headers

        parsed_response = JSON.parse(response.body)
        first_parsed_response_object, second_parsed_response_object = parsed_response['attendances']
        first_input_object, second_input_object = valid_batch[:attendance_batch]

        expect(DateTime.parse(first_parsed_response_object['check_in']))
          .to be_within(1.second)
          .of(DateTime.parse(first_input_object[:check_in]))
        expect(DateTime.parse(first_parsed_response_object['check_out']))
          .to be_within(1.second)
          .of(DateTime.parse(first_input_object[:check_out]))
        expect(first_parsed_response_object['child_approval_id'])
          .to eq(
            Child.find(first_input_object[:child_id])
              .active_child_approval(Date.parse(first_input_object[:check_in])).id
          )

        expect(DateTime.parse(second_parsed_response_object['check_in']))
          .to be_within(1.second)
          .of(DateTime.parse(second_input_object[:check_in]))
        expect(DateTime.parse(second_parsed_response_object['check_out']))
          .to be_within(1.second)
          .of(DateTime.parse(second_input_object[:check_out]))
        expect(second_parsed_response_object['child_approval_id'])
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
              check_in: '2021/03/25 12:33pm',
              check_out: '2021/03/25 5:16pm',
              child_id: children[0].id
            },
            {
              check_in: '2021/03/28 8:12am',
              check_out: '2021/03/28 11:48am'
            }
          ]
        }
      end

      it 'returns json errors' do
        post '/api/v1/attendance_batches', params: batch_with_one_invalid_record, headers: headers

        parsed_response = JSON.parse(response.body)
        first_parsed_response_object, = parsed_response['attendances']
        first_input_object, = batch_with_one_invalid_record[:attendance_batch]

        expect(DateTime.parse(first_parsed_response_object['check_in']))
          .to be_within(1.second)
          .of(DateTime.parse(first_input_object[:check_in]))
        expect(DateTime.parse(first_parsed_response_object['check_out']))
          .to be_within(1.second)
          .of(DateTime.parse(first_input_object[:check_out]))
        expect(first_parsed_response_object['child_approval_id'])
          .to eq(
            Child.find(first_input_object[:child_id])
              .active_child_approval(Date.parse(first_input_object[:check_in])).id
          )

        expect(parsed_response['meta']['errors']).to be_present
        expect(parsed_response['meta']['errors'].map(&:keys).flatten).to eq(['child_id'])
        expect(parsed_response['meta']['errors'].map(&:values).flatten).to eq(["can't be blank"])
        expect(response).to match_response_schema('attendance_batch')
      end
    end

    context 'when missing required fields on all records' do
      let(:batch_with_all_invalid_records) do
        {
          attendance_batch:
          [
            {
              check_in: '2021/03/25 12:33pm',
              check_out: '2021/03/25 5:16pm'
            },
            {
              check_in: '2021/03/28 8:12am',
              check_out: '2021/03/28 11:48am'
            }
          ]
        }
      end

      it 'returns json errors' do
        post '/api/v1/attendance_batches', params: batch_with_all_invalid_records, headers: headers

        parsed_response = JSON.parse(response.body)

        expect(parsed_response['meta']['errors']).to be_present
        expect(parsed_response['meta']['errors'].map(&:keys).flatten).to eq(%w[child_id child_id])
        expect(parsed_response['meta']['errors'].map(&:values).flatten).to eq(["can't be blank", "can't be blank"])
        expect(response).to match_response_schema('attendance_batch')
      end
    end
  end
end
