# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_context 'with nebraska child created for dashboard' do
  let(:child) { create(:necc_child, effective_date: Time.zone.parse('June 1st, 2021')) }
  let(:qris_bump) { 1.05**1 }
  let(:hourly_rate) { Money.from_amount(5.15) }
  let(:daily_rate) { Money.from_amount(25.15) }
  let(:family_fee) { child.active_nebraska_approval_amount(attendance_date).family_fee }
  let(:timezone) { ActiveSupport::TimeZone.new(child.timezone) }
  let(:child_approval) { child.child_approvals.first }
  let(:attendance_date) { Time.new(2021, 7, 4, 0, 0, 0, timezone).to_date }
  let(:prior_month_check_in) { child_approval.effective_on.in_time_zone(child.timezone).at_beginning_of_day }

  before do
    child_business = child.child_businesses.find_by(currently_active: true)

    Business.find(child_business.business_id)&.update!(accredited: true, quality_rating: 'step_four')
    child_approval.update!(
      attributes_for(:child_approval)
      .merge({
               full_days: 200,
               hours: 1800,
               special_needs_rate: false
             })
    )
    child.schedules.each(&:reload)
  end
end

RSpec.shared_context 'with nebraska rates created for dashboard' do
  before do
    business = child.child_businesses.find_by(currently_active: true).business
    create(
      :accredited_hourly_ldds_rate,
      license_type: business.license_type,
      amount: 5.15,
      effective_on: Time.zone.parse('April 1st, 2021'),
      expires_on: nil
    )
    create(
      :accredited_daily_ldds_rate,
      license_type: business.license_type,
      amount: 25.15,
      effective_on: Time.zone.parse('April 1st, 2021'),
      expires_on: nil
    )
  end
end

RSpec.shared_context 'with attendances on July 4th and 5th' do
  before do
    service_day = create(
      :service_day,
      child:,
      date: attendance_date.in_time_zone(child.timezone).at_beginning_of_day
    )
    create(
      :attendance,
      child_approval:,
      service_day:,
      check_in: attendance_date.in_time_zone(child.timezone).to_datetime + 3.hours,
      check_out: attendance_date.in_time_zone(child.timezone).to_datetime + 6.hours
    )

    next_day = Helpers.next_attendance_day(child_approval:).in_time_zone(child.timezone)

    second_service_day = create(
      :service_day,
      date: next_day.at_beginning_of_day,
      child:
    )
    create(
      :attendance,
      child_approval:,
      service_day: second_service_day,
      check_in: next_day + 3.hours,
      check_out: next_day + 9.hours
    )
    perform_enqueued_jobs
    ServiceDay.find_each(&:reload)
  end
end

RSpec.shared_context 'with an hourly attendance' do
  before do
    new_date = Helpers.next_attendance_day(child_approval:)
    service_day = create(:service_day, child:, date: new_date)
    create(
      :attendance,
      child_approval:,
      service_day:,
      check_in: new_date + 3.hours,
      check_out: new_date + 6.hours + 15.minutes
    )
    perform_enqueued_jobs
    ServiceDay.find_each(&:reload)
  end
end

RSpec.shared_context 'with a daily attendance' do
  before do
    new_date = Helpers.next_attendance_day(child_approval:)
    service_day = create(:service_day, child:, date: new_date)
    create(
      :attendance,
      child_approval:,
      service_day:,
      check_in: Helpers.next_attendance_day(child_approval:) + 3.hours,
      check_out: Helpers.next_attendance_day(child_approval:) + 9.hours + 18.minutes
    )
    perform_enqueued_jobs
    ServiceDay.find_each(&:reload)
  end
end

RSpec.shared_context 'with a daily plus hourly attendance' do
  before do
    new_date = Helpers.next_attendance_day(child_approval:)
    service_day = create(:service_day, child:, date: new_date)
    create(
      :attendance,
      child_approval:,
      service_day:,
      check_in: Helpers.next_attendance_day(child_approval:) + 3.hours,
      check_out: Helpers.next_attendance_day(child_approval:) + 14.hours + 47.minutes
    )
    perform_enqueued_jobs
    ServiceDay.find_each(&:reload)
  end
end

RSpec.shared_context 'with a daily plus hourly max attendance' do
  before do
    new_date = Helpers.next_attendance_day(child_approval:)
    service_day = create(:service_day, child:, date: new_date)
    create(
      :attendance,
      child_approval:,
      service_day:,
      check_in: Helpers.next_attendance_day(child_approval:) + 3.hours,
      check_out: Helpers.next_attendance_day(child_approval:) + 21.hours + 5.minutes
    )
    perform_enqueued_jobs
    ServiceDay.find_each(&:reload)
  end
end

RSpec.shared_context 'with an absence' do
  before do
    Helpers.build_nebraska_absence_list(num: 1, child_approval:)
    perform_enqueued_jobs
    ServiceDay.find_each(&:reload)
  end
end

RSpec.shared_context 'with a covid absence' do
  before do
    Helpers.build_nebraska_absence_list(num: 1, type: 'covid_absence', child_approval:)
    perform_enqueued_jobs
    ServiceDay.find_each(&:reload)
  end
end

RSpec.shared_context 'with a prior month hourly attendance' do |extra_days|
  before do
    extra_days ||= 0
    child.reload
    new_date = prior_month_check_in + extra_days.days
    service_day = create(:service_day, child:, date: new_date)
    create(
      :attendance,
      child_approval:,
      service_day:,
      check_in: new_date,
      check_out: new_date + 3.hours
    )
    perform_enqueued_jobs
    ServiceDay.find_each(&:reload)
  end
end

RSpec.shared_context 'with a prior month daily attendance' do |extra_days|
  before do
    extra_days ||= 0
    child.reload
    new_date = prior_month_check_in + extra_days.days
    service_day = create(:service_day, child:, date: new_date)
    create(
      :attendance,
      child_approval:,
      service_day:,
      check_in: prior_month_check_in + extra_days.days,
      check_out: prior_month_check_in + extra_days.days + 7.hours
    )
    perform_enqueued_jobs
    ServiceDay.find_each(&:reload)
  end
end

RSpec.shared_context 'with a prior month covid absence' do |extra_days|
  before do
    extra_days ||= 0
    date = prior_month_check_in + extra_days.days
    schedule = child.schedules.find_by(
      weekday: date.wday,
      effective_on: ..date,
      expires_on: [date.., nil]
    )
    create(
      :service_day,
      child:,
      date:,
      schedule:,
      absence_type: 'covid_absence'
    )
    perform_enqueued_jobs
    ServiceDay.find_each(&:reload)
  end
end

RSpec.shared_context 'with a prior month absence' do |extra_days|
  before do
    extra_days ||= 0
    date = prior_month_check_in + extra_days.days
    schedule = child.schedules.find_by(
      weekday: date.wday,
      effective_on: ..date,
      expires_on: [date.., nil]
    )
    create(
      :service_day,
      child:,
      date:,
      schedule:,
      absence_type: 'absence'
    )
    perform_enqueued_jobs
    ServiceDay.find_each(&:reload)
  end
end

RSpec.shared_context 'with illinois child created for dashboard' do
  let(:child) { create(:child_in_illinois, effective_date: Time.zone.parse('June 1st, 2022')) }
  let(:timezone) { ActiveSupport::TimeZone.new(child.timezone) }
  let(:attendance_date) { Time.new(2022, 7, 4, 0, 0, 0, timezone).to_date }
  let(:child_approval) { child.child_approvals.first }

  before do
    service_day = create(
      :service_day,
      child:,
      date: attendance_date.in_time_zone(child.timezone).at_beginning_of_day
    )
    create(
      :attendance,
      child_approval:,
      service_day:,
      check_in: attendance_date.in_time_zone(child.timezone).to_datetime + 3.hours,
      check_out: attendance_date.in_time_zone(child.timezone).to_datetime + 6.hours
    )

    next_day = Helpers.next_attendance_day(child_approval:).in_time_zone(child.timezone)

    second_service_day = create(
      :service_day,
      date: next_day.at_beginning_of_day,
      child:
    )
    create(
      :attendance,
      child_approval:,
      service_day: second_service_day,
      check_in: next_day + 3.hours,
      check_out: next_day + 9.hours
    )
    perform_enqueued_jobs
    ServiceDay.find_each(&:reload)
  end
end
