# frozen_string_literal: true

require 'rails_helper'

module Wonderschool
  module Necc
    RSpec.describe OnboardingCaseImporter, type: :model do
      let!(:file_name) { 'file_name.csv' }
      let!(:source_bucket) { 'source_bucket' }
      let!(:archive_bucket) { 'archive_bucket' }
      let!(:stubbed_client) { instance_double(AwsClient) }
      let!(:stubbed_aws_s3_client) { instance_double(Aws::S3::Client, delete_object: nil) }

      let!(:onboarding_csv) { File.read(Rails.root.join('spec/fixtures/files/wonderschool_necc_onboarding_data.csv')) }
      let!(:invalid_csv) { File.read(Rails.root.join('spec/fixtures/files/invalid_format.csv')) }
      let!(:missing_field_csv) do
        File.read(Rails.root.join('spec/fixtures/files/wonderschool_necc_onboarding_data_missing_field.csv'))
      end

      let!(:first_user) { create(:confirmed_user, email: 'rebecca@rebecca.com') }
      let!(:second_user) { create(:confirmed_user, email: 'kate@kate.com') }

      before do
        # this lands us in the 'effective' period for all the approvals in the CSV fixture
        travel_to Date.parse('May 20th, 2021')
        allow(Rails.application.config).to receive(:aws_necc_onboarding_bucket) { source_bucket }
        allow(Rails.application.config).to receive(:aws_necc_onboarding_archive_bucket) { archive_bucket }
        allow(AwsClient).to receive(:new) { stubbed_client }
        allow(stubbed_client).to receive(:list_file_names).with(source_bucket) { [file_name] }
      end

      describe '#call' do
        context 'with valid data' do
          before do
            allow(stubbed_client).to receive(:get_file_contents).with(source_bucket, file_name) { onboarding_csv }
            allow(stubbed_client).to receive(:archive_file).with(source_bucket, archive_bucket, file_name)
          end

          it 'creates case records for every row in the file, idempotently' do
            expect { described_class.new.call }
              .to change(Child, :count)
              .from(0).to(5)
              .and change(Business, :count)
              .from(0).to(2)
              .and change(ChildApproval, :count)
              .from(0).to(5)
              .and change(Approval, :count)
              .from(0).to(3)
              .and change(NebraskaApprovalAmount, :count)
              .from(0).to(6)
            expect { described_class.new.call }
              .to not_change(Child, :count)
              .and not_change(Business, :count)
              .and not_change(ChildApproval, :count)
              .and not_change(Approval, :count)
              .and not_change(NebraskaApprovalAmount, :count)
          end

          it 'creates case records for the correct child with the correct data' do
            described_class.new.call
            thomas = Child.find_by(full_name: 'Thomas Eddleman')
            expect(thomas).to have_attributes(
              {
                dhs_id: '14047907',
                date_of_birth: Date.parse('2010-09-01'),
                enrolled_in_school: false,
                wonderschool_id: '37821'
              }
            )
            expect(thomas.business).to have_attributes(
              {
                name: "Rebecca's Childcare",
                zipcode: '68845',
                county: 'Corke',
                qris_rating: 'step_four',
                accredited: true
              }
            )
            expect(thomas.user).to eq(first_user)
            expect(thomas.approvals.first).to have_attributes(
              {
                case_number: '14635435',
                effective_on: Date.parse('2020-09-01'),
                expires_on: Date.parse('2021-08-31')
              }
            )
            expect(thomas.child_approvals.first).to have_attributes(
              {
                full_days: 276,
                hours: 1656,
                special_needs_rate: false,
                special_needs_daily_rate: nil,
                special_needs_hourly_rate: nil,
                authorized_weekly_hours: 30
              }
            )
            expect(thomas.child_approvals.first.nebraska_approval_amounts.count).to eq(1)
            expect(thomas.child_approvals.first.nebraska_approval_amounts.first).to have_attributes(
              {
                effective_on: Date.parse('2020-09-01'),
                expires_on: Date.parse('2021-08-31'),
                family_fee: 0,
                allocated_family_fee: 0
              }
            )
            becky = Child.find_by(full_name: 'Becky Falzone')
            expect(becky).to have_attributes(
              {
                dhs_id: '69370816',
                date_of_birth: Date.parse('2013-12-26'),
                enrolled_in_school: false,
                wonderschool_id: '37827'
              }
            )
            expect(becky.business).to have_attributes(
              {
                name: "Kate's Kids",
                zipcode: '68845',
                county: 'Corke',
                qris_rating: 'step_five',
                accredited: false
              }
            )
            expect(becky.user).to eq(second_user)
            expect(becky.approvals.first).to have_attributes(
              {
                case_number: '56582912',
                effective_on: Date.parse('2020-11-24'),
                expires_on: Date.parse('2021-11-23')
              }
            )
            expect(becky.child_approvals.first).to have_attributes(
              {
                full_days: 330,
                hours: 1760,
                special_needs_rate: true,
                special_needs_daily_rate: 90.77,
                special_needs_hourly_rate: 9.43,
                authorized_weekly_hours: 45
              }
            )
            expect(becky.child_approvals.first.nebraska_approval_amounts.count).to eq(2)
            expect(becky.child_approvals.first.nebraska_approval_amounts.find_by(
                     effective_on: Date.parse('2020-11-24')
                   )).to have_attributes(
                     {
                       effective_on: Date.parse('2020-11-24'),
                       expires_on: Date.parse('2021-05-23'),
                       family_fee: 60.00,
                       allocated_family_fee: 60.00
                     }
                   )
            expect(becky.child_approvals.first.nebraska_approval_amounts.find_by(
                     effective_on: Date.parse('2021-05-24')
                   )).to have_attributes(
                     {
                       effective_on: Date.parse('2021-05-24'),
                       expires_on: Date.parse('2021-11-23'),
                       family_fee: 85.00,
                       allocated_family_fee: 85.00
                     }
                   )
          end

          it "continues processing if the user doesn't exist" do
            first_user.destroy!
            described_class.new.call
            expect(Child.find_by(full_name: 'Thomas Eddleman')).to be_nil
            expect(Child.find_by(full_name: 'Becky Falzone')).to be_present
            expect(stubbed_aws_s3_client).not_to have_received(:delete_object)
          end

          it 'skips the child if the exact same child at the exact same business already exists' do
            business = create(
              :business,
              user: first_user,
              name: "Rebecca's Childcare",
              zipcode: '68845',
              county: 'Corke',
              license_type: 'Family Child Care Home II'.downcase.tr(' ', '_')
            )
            approval = create(
              :approval,
              case_number: '14635435',
              effective_on: '2020-09-01',
              expires_on: '2021-08-31',
              create_children: false
            )
            create(:child, full_name: 'Thomas Eddleman', business: business, approvals: [approval])
            expect { described_class.new.call }
              .to change(Child, :count)
              .from(1).to(5)
              .and change(Business, :count)
              .from(1).to(2)
              .and change(ChildApproval, :count)
              .from(1).to(5)
              .and change(Approval, :count)
              .from(1).to(3)
              .and change(NebraskaApprovalAmount, :count)
              .from(0).to(5)
          end
        end

        context 'with invalid data' do
          it 'continues processing if the record is invalid or missing a required field' do
            allow(stubbed_client).to receive(:get_file_contents).with(source_bucket, file_name) { invalid_csv }
            allow(stubbed_client).to receive(:archive_file).with(source_bucket, archive_bucket, file_name)
            described_class.new.call
            expect(Child.find_by(full_name: 'Thomas Eddleman')).to be_nil
            expect(Child.find_by(full_name: 'Becky Falzone')).to be_nil
            allow(stubbed_client).to receive(:get_file_contents).with(source_bucket, file_name) { missing_field_csv }
            allow(stubbed_client).to receive(:archive_file).with(source_bucket, archive_bucket, file_name)
            described_class.new.call
            expect(Child.find_by(full_name: 'Thomas Eddleman')).to be_nil
            expect(Child.find_by(full_name: 'Becky Falzone')).to be_nil
          end
        end
      end
    end
  end
end
