# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IllinoisOnboardingCaseImporter do
  let!(:file_name) { 'file_name.csv' }
  let!(:source_bucket) { 'source_bucket' }
  let!(:archive_bucket) { 'archive_bucket' }
  let!(:stubbed_client) { instance_double(AwsClient) }

  let!(:onboarding_csv) do
    Rails.root.join('spec/fixtures/files/illinois_onboarding/illinois_onboarding_data.csv').read
  end
  let!(:renewal_csv) do
    Rails.root.join('spec/fixtures/files/wonderschool_necc_onboarding_renewal_data.csv').read
  end
  let!(:invalid_csv) { Rails.root.join('spec/fixtures/files/invalid_format.csv').read }
  let!(:missing_field_csv) do
    Rails.root.join('spec/fixtures/files/wonderschool_necc_onboarding_data_missing_field.csv').read
  end

  let!(:first_user) { create(:confirmed_user, email: 'rebecca@rebecca.com') }
  let!(:second_user) { create(:confirmed_user, email: 'kate@kate.com') }

  before do
    # this lands us in the 'effective' period for all the approvals in the CSV fixture
    travel_to Date.parse('May 20th, 2021').in_time_zone(first_user.timezone)
    allow(Rails.application.config).to receive(:aws_onboarding_bucket) { source_bucket }
    allow(Rails.application.config).to receive(:aws_onboarding_archive_bucket) { archive_bucket }
    allow(AwsClient).to receive(:new) { stubbed_client }
    allow(stubbed_client).to receive(:list_file_names).with(source_bucket, 'IL/') { [file_name] }
  end

  after { travel_back }

  describe '#call' do
    context 'with valid data' do
      before do
        allow(stubbed_client).to receive(:get_file_contents).with(source_bucket, file_name) { onboarding_csv }
        allow(stubbed_client).to receive(:archive_file).with(source_bucket, archive_bucket, file_name)
      end

      it 'checks the date format when date format is correct' do
        check = described_class.new.send(:check_date_format, '2023-12-31')
        expect(check).to be(true)
      end

      it 'checks the date format when date format is wrong' do
        check = described_class.new.send(:check_date_format, '31-12-2023')
        expect(check).to be(false)
      end

      it 'creates case records for every row in the file, idempotently' do
        expect do
          described_class.new.call
          perform_enqueued_jobs
        end
          .to change(Child, :count)
          .from(0).to(5)
          .and change(Business, :count)
          .from(0).to(2)
          .and change(ChildApproval, :count)
          .from(0).to(5)
          .and change(Approval, :count)
          .from(0).to(3)
          .and change(IllinoisApprovalAmount, :count)
          .from(0).to(56)
          .and not_change(ServiceDay, :count)
          .and not_raise_error
        expect do
          described_class.new.call
          perform_enqueued_jobs
        end
          .to not_change(Child, :count)
          .and not_change(Business, :count)
          .and not_change(ChildApproval, :count)
          .and not_change(Approval, :count)
          .and not_change(IllinoisApprovalAmount, :count)
          .and not_change(ServiceDay, :count)
          .and not_raise_error
      end

      it 'creates case records for the correct child with the correct data' do
        described_class.new.call
        thomas = Child.find_by(first_name: 'Thomas', last_name: 'Eddleman')

        expect(thomas).to have_attributes(
          {
            dhs_id: '14047907',
            date_of_birth: Date.parse('2010-09-01'),
            wonderschool_id: '37821'
          }
        )
        expect(thomas.child_businesses.find_by(currently_active: true)&.business).to have_attributes(
          {
            name: "Rebecca's Childcare",
            zipcode: '68845',
            county: 'Corke',
            quality_rating: nil,
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
            authorized_weekly_hours: 30.0,
            enrolled_in_school: true
          }
        )
        expect(thomas.child_approvals.first.illinois_approval_amounts.count).to eq(12)
        expect(thomas.child_approvals.first.illinois_approval_amounts.order(:month).first).to have_attributes(
          {
            month: 'Tue, 01 Sep 2020'.to_date,
            part_days_approved_per_week: 2,
            full_days_approved_per_week: 3
          }
        )
        becky = Child.find_by(first_name: 'Becky', last_name: 'Falzone')
        expect(becky).to have_attributes(
          {
            dhs_id: '69370816',
            date_of_birth: Date.parse('2013-12-26'),
            wonderschool_id: '37827'
          }
        )
        expect(becky.child_businesses.find_by(currently_active: true).business).to have_attributes(
          {
            name: "Kate's Kids",
            zipcode: '68845',
            county: 'Corke',
            quality_rating: nil,
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
            special_needs_daily_rate: Money.from_amount(90.77),
            special_needs_hourly_rate: Money.from_amount(9.43),
            authorized_weekly_hours: 45.0
          }
        )
        expect(becky.child_approvals.first.illinois_approval_amounts.count).to eq(13)
        expect(becky.child_approvals.first.illinois_approval_amounts.first).to have_attributes(
          {
            part_days_approved_per_week: 2,
            full_days_approved_per_week: 3
          }
        )
      end

      it "continues processing if the user doesn't exist" do
        first_user.destroy!
        described_class.new.call
        expect(Child.find_by(first_name: 'Thomas', last_name: 'Eddleman')).to be_nil
        expect(Child.find_by(first_name: 'Becky', last_name: 'Falzone')).to be_present
        expect(stubbed_client).to have_received(:archive_file)
      end

      it 'skips the child if all their existing details are the same' do
        approval = create(
          :approval,
          case_number: '14635435',
          effective_on: '2020-09-01',
          expires_on: '2021-08-31',
          create_children: false
        )
        child = create(:child_in_illinois,
                       first_name: 'Thomas',
                       last_name: 'Eddleman',
                       date_of_birth: '2010-09-01',
                       wonderschool_id: '37821',
                       dhs_id: '14047907',
                       approvals: [approval])
        child.reload.child_approvals.first.update!(
          authorized_weekly_hours: 30.0,
          full_days: 276,
          hours: 1656,
          special_needs_rate: false,
          special_needs_hourly_rate: nil,
          special_needs_daily_rate: nil,
          rate_type: nil,
          rate_id: nil
        )
        expect { described_class.new.call }
          .to change(Child, :count)
          .from(1).to(5)
          .and change(Business, :count)
          .from(1).to(3)
          .and change(ChildApproval, :count)
          .from(1).to(5)
          .and change(Approval, :count)
          .from(1).to(3)
          .and change(IllinoisApprovalAmount, :count)
          .from(12).to(56)
          .and not_raise_error
      end

      it 'updates the existing details if the approval dates are the same but other details are different' do
        approval = create(
          :approval,
          case_number: '14635435',
          effective_on: '2020-09-01',
          expires_on: '2021-08-31',
          create_children: false
        )
        child = create(:child_in_illinois,
                       first_name: 'Thomas',
                       last_name: 'Eddleman',
                       date_of_birth: '2010-09-01',
                       wonderschool_id: '37821',
                       dhs_id: '14047907',
                       approvals: [approval])
        child.reload.child_approvals.first.update!(
          enrolled_in_school: false,
          authorized_weekly_hours: 30.0,
          full_days: 13,
          hours: 12,
          special_needs_rate: true,
          special_needs_hourly_rate: 12,
          special_needs_daily_rate: 15,
          rate_type: nil,
          rate_id: nil
        )
        expect { described_class.new.call }
          .to change(Child, :count)
          .from(1).to(5)
          .and change(Business, :count)
          .from(1).to(3)
          .and change(ChildApproval, :count)
          .from(1).to(5)
          .and change(Approval, :count)
          .from(1).to(3)
          .and change(IllinoisApprovalAmount, :count)
          .from(12).to(56)
          .and not_raise_error
        child.reload
        expect(child.child_approvals.first.full_days).to eq(276)
        expect(child.child_approvals.first.hours).to eq(1656)
        expect(child.child_approvals.first.special_needs_rate).to be(false)
        expect(child.child_approvals.first.special_needs_daily_rate).to be_nil
        expect(child.child_approvals.first.special_needs_hourly_rate).to be_nil
      end

      it 'processes existing child with new approval details if new approval dates are different' do
        approval = create(
          :approval,
          case_number: '14635435',
          effective_on: '2019-09-01',
          expires_on: '2020-08-31',
          create_children: false
        )
        create(:child,
               first_name: 'Thomas',
               last_name: 'Eddleman',
               date_of_birth: '2010-09-01',
               wonderschool_id: '37821',
               dhs_id: '14047907',
               approvals: [approval],
               effective_date: Time.zone.parse('2019-09-01'))
        expect { described_class.new.call }
          .to change(Child, :count)
          .from(1).to(5)
          .and change(Business, :count)
          .from(1).to(3)
          .and change(ChildApproval, :count)
          .from(1).to(6)
          .and change(Approval, :count)
          .from(1).to(4)
          .and change(IllinoisApprovalAmount, :count)
          .from(0).to(56)
          .and not_raise_error
      end

      it 'updates the child with new approval details if the new approval overlaps' do
        existing_approval = create(
          :approval,
          case_number: '14635435',
          effective_on: '2020-06-01',
          expires_on: '2021-05-31',
          create_children: false
        )
        child = create(:child,
                       first_name: 'Thomas',
                       last_name: 'Eddleman',
                       date_of_birth: '2010-09-01',
                       wonderschool_id: '37821',
                       dhs_id: '14047907',
                       approvals: [existing_approval],
                       effective_date: Time.zone.parse('2020-06-01'))
        expect { described_class.new.call }
          .to change(Child, :count)
          .from(1).to(5)
          .and change(Business, :count)
          .from(1).to(3)
          .and change(ChildApproval, :count)
          .from(1).to(6)
          .and change(Approval, :count)
          .from(1).to(4)
          .and change(IllinoisApprovalAmount, :count)
          .from(0).to(56)
          .and not_raise_error
        child.reload
        expect(
          child.approvals.reject do |app|
            app == existing_approval
          end.first.expires_on
        ).to eq(Date.parse('2021-08-31'))
        expect(existing_approval.reload.expires_on).to eq(Date.parse('2020-08-31'))
      end
    end

    context 'with expired case data' do
      before do
        travel_back
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
          .and change(IllinoisApprovalAmount, :count)
          .from(0).to(56)
          .and not_raise_error
        expect { described_class.new.call }
          .to not_change(Child, :count)
          .and not_change(Business, :count)
          .and not_change(ChildApproval, :count)
          .and not_change(Approval, :count)
          .and not_change(IllinoisApprovalAmount, :count)
          .and not_raise_error
      end

      it 'creates case records for the correct child with the correct data' do
        described_class.new.call
        thomas = Child.find_by(first_name: 'Thomas', last_name: 'Eddleman')
        expect(thomas).to have_attributes(
          {
            dhs_id: '14047907',
            date_of_birth: Date.parse('2010-09-01'),
            wonderschool_id: '37821'
          }
        )
        expect(thomas.child_businesses.find_by(currently_active: true).business).to have_attributes(
          {
            name: "Rebecca's Childcare",
            zipcode: '68845',
            county: 'Corke',
            quality_rating: nil,
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
            authorized_weekly_hours: 30.0,
            enrolled_in_school: true
          }
        )
        expect(thomas.child_approvals.first.illinois_approval_amounts.count).to eq(12)
        becky = Child.find_by(first_name: 'Becky', last_name: 'Falzone')
        expect(becky).to have_attributes(
          {
            dhs_id: '69370816',
            date_of_birth: Date.parse('2013-12-26'),
            wonderschool_id: '37827'
          }
        )
        expect(becky.child_businesses.find_by(currently_active: true).business).to have_attributes(
          {
            name: "Kate's Kids",
            zipcode: '68845',
            county: 'Corke',
            quality_rating: nil,
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
            special_needs_daily_rate: Money.from_amount(90.77),
            special_needs_hourly_rate: Money.from_amount(9.43),
            authorized_weekly_hours: 45.0
          }
        )
        expect(becky.child_approvals.first.illinois_approval_amounts.count).to eq(13)
      end

      it "continues processing if the user doesn't exist" do
        first_user.destroy!
        described_class.new.call
        expect(Child.find_by(first_name: 'Thomas', last_name: 'Eddleman')).to be_nil
        expect(Child.find_by(first_name: 'Becky', last_name: 'Falzone')).to be_present
        expect(stubbed_client).to have_received(:archive_file)
      end

      it 'skips the child if all their existing details are the same' do
        approval = create(
          :approval,
          case_number: '14635435',
          effective_on: '2020-09-01',
          expires_on: '2021-08-31',
          create_children: false
        )
        child = create(:child,
                       first_name: 'Thomas',
                       last_name: 'Eddleman',
                       date_of_birth: '2010-09-01',
                       wonderschool_id: '37821',
                       dhs_id: '14047907',
                       approvals: [approval])
        child.reload.child_approvals.first.update!(
          authorized_weekly_hours: 30.0,
          full_days: 276,
          hours: 1656,
          special_needs_rate: false,
          special_needs_hourly_rate: nil,
          special_needs_daily_rate: nil,
          rate_type: nil,
          rate_id: nil
        )
        #   child.reload.illinois_approval_amounts.first.update!(
        #   effective_on: Date.parse('2020-09-01'),
        #   expires_on: Date.parse('2021-08-31'),
        #   )
        expect { described_class.new.call }
          .to change(Child, :count)
          .from(1).to(5)
          .and change(Business, :count)
          .from(1).to(3)
          .and change(ChildApproval, :count)
          .from(1).to(5)
          .and change(Approval, :count)
          .from(1).to(3)
          .and change(IllinoisApprovalAmount, :count)
          .from(0).to(56)
          .and not_raise_error
      end

      it 'updates the existing details if the approval dates are the same but other details are different' do
        approval = create(
          :approval,
          case_number: '14635435',
          effective_on: '2020-09-01',
          expires_on: '2021-08-31',
          create_children: false
        )
        child = create(:child,
                       first_name: 'Thomas',
                       last_name: 'Eddleman',
                       date_of_birth: '2010-09-01',
                       wonderschool_id: '37821',
                       dhs_id: '14047907',
                       approvals: [approval])
        child.reload.child_approvals.first.update!(
          enrolled_in_school: false,
          authorized_weekly_hours: 30.0,
          full_days: 13,
          hours: 12,
          special_needs_rate: true,
          special_needs_hourly_rate: 12,
          special_needs_daily_rate: 15,
          rate_type: nil,
          rate_id: nil
        )
        expect { described_class.new.call }
          .to change(Child, :count)
          .from(1).to(5)
          .and change(Business, :count)
          .from(1).to(3)
          .and change(ChildApproval, :count)
          .from(1).to(5)
          .and change(Approval, :count)
          .from(1).to(3)
          .and change(IllinoisApprovalAmount, :count)
          .from(0).to(56)
          .and not_raise_error
        child.reload
        expect(child.child_approvals.first.full_days).to eq(276)
        expect(child.child_approvals.first.hours).to eq(1656)
        expect(child.child_approvals.first.special_needs_rate).to be(false)
        expect(child.child_approvals.first.special_needs_daily_rate).to be_nil
        expect(child.child_approvals.first.special_needs_hourly_rate).to be_nil
      end

      it 'processes existing child with new approval details if new approval dates are different' do
        approval = create(
          :approval,
          case_number: '14635435',
          effective_on: '2019-09-01',
          expires_on: '2020-08-31',
          create_children: false
        )
        create(:child,
               first_name: 'Thomas',
               last_name: 'Eddleman',
               date_of_birth: '2010-09-01',
               wonderschool_id: '37821',
               dhs_id: '14047907',
               approvals: [approval],
               effective_date: Time.zone.parse('2019-09-01'))
        expect { described_class.new.call }
          .to change(Child, :count)
          .from(1).to(5)
          .and change(Business, :count)
          .from(1).to(3)
          .and change(ChildApproval, :count)
          .from(1).to(6)
          .and change(Approval, :count)
          .from(1).to(4)
          .and change(IllinoisApprovalAmount, :count)
          .from(0).to(56)
          .and not_raise_error
      end

      it 'updates the child with new approval details if the new approval overlaps' do
        approval = create(
          :approval,
          case_number: '14635435',
          effective_on: '2020-06-01',
          expires_on: '2021-05-31',
          create_children: false
        )
        child = create(:child,
                       first_name: 'Thomas',
                       last_name: 'Eddleman',
                       date_of_birth: '2010-09-01',
                       wonderschool_id: '37821',
                       dhs_id: '14047907',
                       approvals: [approval],
                       effective_date: Time.zone.parse('2020-06-01'))
        expect { described_class.new.call }
          .to change(Child, :count)
          .from(1).to(5)
          .and change(Business, :count)
          .from(1).to(3)
          .and change(ChildApproval, :count)
          .from(1).to(6)
          .and change(Approval, :count)
          .from(1).to(4)
          .and change(IllinoisApprovalAmount, :count)
          .from(0).to(56)
          .and not_raise_error
        child.reload
        expect((child.approvals.reject { |app| app == approval }).first.expires_on).to eq(Date.parse('2021-08-31'))
        expect(approval.reload.expires_on).to eq(Date.parse('2020-08-31'))
      end
    end

    context 'when renewing' do
      before do
        allow(stubbed_client).to receive(:get_file_contents).with(source_bucket, file_name) { renewal_csv }
        allow(stubbed_client).to receive(:archive_file).with(source_bucket, archive_bucket, file_name)
      end

      it 'creates case records for the correct child with the correct data' do
        described_class.new.call
        thomas = Child.find_by(first_name: 'Thomas', last_name: 'Eddleman')
        expect(thomas.approvals.length).to eq(2)
        expect(thomas.approvals.pluck(:effective_on, :expires_on)).to match_array(
          [
            [Date.parse('2020-09-01'), Date.parse('2021-08-31')],
            [Date.parse('2021-09-01'), Date.parse('2022-08-31')]
          ]
        )
        first_approval = thomas.approvals.find_by(effective_on: '2020-09-01')
        second_approval = thomas.approvals.find_by(effective_on: '2021-09-01')
        expect(first_approval.child_approvals.length).to eq(1)
        expect(first_approval.child_approvals.first).to have_attributes(
          {
            full_days: 276,
            hours: 1656,
            special_needs_rate: false,
            special_needs_daily_rate: nil,
            special_needs_hourly_rate: nil,
            authorized_weekly_hours: 30.0
          }
        )
        expect(second_approval.child_approvals.length).to eq(1)
        expect(second_approval.child_approvals.first).to have_attributes(
          {
            full_days: 276,
            hours: 1656,
            special_needs_rate: false,
            special_needs_daily_rate: nil,
            special_needs_hourly_rate: nil,
            authorized_weekly_hours: 30.0
          }
        )
        expect(first_approval.child_approvals.first.illinois_approval_amounts.length).to eq(12)
      end
    end

    context 'with updated approval periods' do
      before do
        allow(stubbed_client).to receive(:get_file_contents).with(source_bucket, file_name) { onboarding_csv }
        allow(stubbed_client).to receive(:archive_file).with(source_bucket, archive_bucket, file_name)
      end

      it 'updates the existing details if approval periods are different' do
        approval = create(
          :approval,
          case_number: '56582912',
          effective_on: '2020-11-24',
          expires_on: '2021-11-23',
          create_children: false
        )
        child = create(:child,
                       first_name: 'Becky',
                       last_name: 'Falzone',
                       date_of_birth: '2013-12-26',
                       wonderschool_id: '37827',
                       dhs_id: '69370816',
                       approvals: [approval])
        child.reload.child_approvals.first.update!(
          enrolled_in_school: false,
          authorized_weekly_hours: 45,
          full_days: 330,
          hours: 1760,
          special_needs_rate: true,
          special_needs_hourly_rate: 9.43,
          special_needs_daily_rate: 90.77,
          rate_type: nil,
          rate_id: nil
        )
        expect { described_class.new.call }
          .to change(Child, :count)
          .from(1).to(5)
          .and change(Business, :count)
          .from(1).to(3)
          .and change(ChildApproval, :count)
          .from(1).to(5)
          .and change(Approval, :count)
          .from(1).to(3)
          .and change(IllinoisApprovalAmount, :count)
          .from(0).to(56)
          .and not_raise_error
        child.reload
        expect(child.child_approvals.first.full_days).to eq(330)
        expect(child.child_approvals.first.hours).to eq(1760)
        expect(child.child_approvals.first.special_needs_rate).to be(true)
        expect(child.child_approvals.first.special_needs_hourly_rate).to eq(Money.from_amount(9.43))
        expect(child.child_approvals.first.special_needs_daily_rate).to eq(Money.from_amount(90.77))
      end
    end

    context 'with invalid data' do
      it 'continues processing if the record is invalid or missing a required field' do
        allow(stubbed_client).to receive(:get_file_contents).with(source_bucket, file_name) { invalid_csv }
        allow(stubbed_client).to receive(:archive_file).with(source_bucket, archive_bucket, file_name)
        described_class.new.call
        expect(Child.find_by(first_name: 'Thomas', last_name: 'Eddleman')).to be_nil
        expect(Child.find_by(first_name: 'Becky', last_name: 'Falzone')).to be_nil
        allow(stubbed_client).to receive(:get_file_contents).with(source_bucket, file_name) { missing_field_csv }
        allow(stubbed_client).to receive(:archive_file).with(source_bucket, archive_bucket, file_name)
        described_class.new.call
        expect(Child.find_by(first_name: 'Thomas', last_name: 'Eddleman')).to be_nil
        expect(Child.find_by(first_name: 'Becky', last_name: 'Falzone')).to be_nil
      end
    end
  end
end
