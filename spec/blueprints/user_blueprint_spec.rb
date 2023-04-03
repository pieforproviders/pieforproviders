# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserBlueprint do
  let(:user) { create(:user) }
  let(:last_month) do
    Helpers
      .prior_weekday(
        Time.current.at_beginning_of_month - 1.month + 10.days, 1
      )
  end
  let(:blueprint) { described_class.render(user) }
  let(:parsed_response) { JSON.parse(blueprint) }

  it 'only includes the expected user fields' do
    expect(parsed_response.keys).to contain_exactly(
      'email',
      'greeting_name',
      'id',
      'language',
      'state'
    )
  end

  context 'when IL view is requested' do
    let(:blueprint) { described_class.render(user, view: :illinois_dashboard) }

    it 'includes IL dashboard fields' do
      expect(parsed_response.keys).to contain_exactly(
        'as_of',
        'businesses',
        'first_approval_effective_date'
        'email'
      )
    end

    context "when there are approvals for this user's children" do
      let(:illinois_business) { create(:business, user: user) }

      before do
        child = create(:child, business: illinois_business)
        service_day = create(:service_day,
                             child: child,
                             date: last_month.at_beginning_of_day)
        create(:attendance,
               check_in: last_month,
               service_day: service_day,
               child_approval: child.child_approvals.first)
        create(:child, :with_two_illinois_attendances, business: illinois_business)
        travel_to user.service_days.order(date: :desc).first.date
      end

      it 'returns the first approval effective date' do
        expect(parsed_response['first_approval_effective_date']).to eq(user.first_approval_effective_date.to_s)
      end

      it "returns the as_of date in the user's timezone" do
        blueprint = described_class.render(user, view: :illinois_dashboard)
        expect(JSON.parse(blueprint)['as_of'])
          .to eq(user.latest_service_day_in_month(Time.current).strftime('%m/%d/%Y'))
      end

      it 'returns the as_of date for the last attendance in the prior month in Illinois' do
        service_day = create(
          :service_day,
          date: last_month.utc.at_beginning_of_day
        )
        attendance = create(:attendance, check_in: last_month.utc, service_day: service_day)

        blueprint = described_class.render(user, view: :illinois_dashboard, filter_date: last_month.utc.at_end_of_month)
        expect(JSON.parse(blueprint)['as_of']).to eq(attendance.check_in.strftime('%m/%d/%Y'))
      end

      it 'returns the as_of date as today for a month with no attendances in Illinois' do
        blueprint = described_class.render(
          user,
          view: :illinois_dashboard,
          filter_date: last_month.at_end_of_month - 6.months
        )
        expect(JSON.parse(blueprint)['as_of']).to eq(Time.current.strftime('%m/%d/%Y'))
      end
    end

    context "when there are no approvals for this user's children" do
      it 'returns nil for the first approval effective date' do
        expect(parsed_response['first_approval_effective_date']).to be_nil
      end

      it "returns the as_of date in the user's timezone" do
        expect(JSON.parse(blueprint)['as_of']).to eq(Time.current.strftime('%m/%d/%Y'))
      end
    end
  end

  context 'when NE view is requested' do
    let(:user) { create(:confirmed_user, :nebraska) }
    let(:nebraska_business) { create(:business, :nebraska_ldds, user: user) }
    let(:blueprint) { described_class.render(user, view: :nebraska_dashboard) }

    it 'includes the user name and all cases' do
      expect(parsed_response.keys).to contain_exactly(
        'as_of',
        'first_approval_effective_date',
        'businesses',
        'max_revenue',
        'total_approved',
        'email'
      )
      expect(parsed_response['max_revenue']).to eq('N/A')
      expect(parsed_response['total_approved']).to eq('N/A')
    end

    context "when there are approvals for this user's children" do
      before do
        child = create(:necc_child, business: nebraska_business)
        service_day = create(:service_day,
                             child: child,
                             date: last_month.at_beginning_of_month)
        create(:attendance,
               check_in: last_month,
               service_day: service_day,
               child_approval: child.child_approvals.first)
        2.times do |idx|
          service_day = create(
            :service_day,
            child: child,
            date: Time.current.at_beginning_of_day + idx.days
          )
          create(:attendance,
                 child_approval: child.child_approvals.first,
                 service_day: service_day,
                 check_in: service_day.date + idx.days)
        end
        perform_enqueued_jobs
        ServiceDay.all.each(&:reload)
      end

      it 'returns the first approval effective date' do
        expect(parsed_response['first_approval_effective_date']).to eq(user.first_approval_effective_date.to_s)
      end

      it "returns the as_of date in the user's timezone" do
        blueprint = described_class.render(user, view: :nebraska_dashboard)
        expect(JSON.parse(blueprint)['as_of'])
          .to eq(user.latest_service_day_in_month(Time.current).strftime('%m/%d/%Y'))
      end

      it 'returns the as_of date for the last attendance in the prior month' do
        child = create(:necc_child, business: nebraska_business)
        service_day = create(:service_day,
                             child: child,
                             date: last_month.utc.at_beginning_of_day)
        attendance = create(:attendance,
                            child_approval: child.child_approvals.first,
                            check_in: last_month.utc,
                            service_day: service_day)
        perform_enqueued_jobs
        ServiceDay.all.each(&:reload)
        blueprint = described_class.render(user, view: :nebraska_dashboard, filter_date: last_month.utc.at_end_of_month)
        expect(JSON.parse(blueprint)['as_of']).to eq(attendance.check_in.strftime('%m/%d/%Y'))
      end

      it 'returns the as_of date as today for a month with no attendances' do
        blueprint = described_class.render(
          user,
          view: :nebraska_dashboard,
          filter_date: last_month.at_end_of_month - 6.months
        )
        expect(JSON.parse(blueprint)['as_of']).to eq(Time.current.strftime('%m/%d/%Y'))
      end
    end

    context "when there are no approvals for this user's children" do
      it 'returns nil for the first approval effective date' do
        expect(parsed_response['first_approval_effective_date']).to be_nil
      end

      it "returns the as_of date in the user's timezone" do
        expect(JSON.parse(blueprint)['as_of']).to eq(Time.current.strftime('%m/%d/%Y'))
      end
    end
  end
end
