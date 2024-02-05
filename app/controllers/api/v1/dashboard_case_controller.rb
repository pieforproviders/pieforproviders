# frozen_string_literal: true

module Api
  module V1
    # Service for dashboard table info
    class DashboardCaseController < ApiController
      def index
        filter_date = params[:filter_date].present? ? params[:filter_date].to_date : Date.current
        start_date = filter_date.at_beginning_of_month.to_s
        end_date = filter_date.at_end_of_month.to_s

        sql_query = "SELECT c.id,
        c.active,
        c.first_name,
        c.last_name,
        b.name as business_name,
        a.case_number,
        c.dhs_id,
        a.effective_on,
        a.expires_on,
        coalesce(
                   (SELECT sum(sd.part_time)
                    FROM service_days sd
                    WHERE sd.child_id = c.id
                      AND sd.absence_type IS NULL
                      AND date BETWEEN '#{start_date}' AND '#{end_date}'), 0) AS part_time,
        coalesce(
                   (SELECT sum(sd.full_time)
                    FROM service_days sd
                    WHERE sd.child_id = c.id
                      AND sd.absence_type IS NULL
                      AND date BETWEEN '#{start_date}' AND '#{end_date}'), 0) AS full_time,
        coalesce(
                   (SELECT count(sd.id)
                    FROM service_days sd
                    WHERE sd.child_id = c.id
                      AND sd.absence_type IS not NULL
                      AND date BETWEEN '#{start_date}' AND '#{end_date}'), 0) AS absences_count,
          (SELECT STRING_AGG(service_date, ', ')
            FROM
              (SELECT TO_CHAR(date, 'MM/dd') AS service_date
              FROM service_days sd
              WHERE sd.child_id = c.id
                AND sd.absence_type IS NOT NULL
                AND date BETWEEN '#{start_date}' AND '#{end_date}'
              ORDER BY date) AS sub_absenses) AS absences,
                ca.authorized_weekly_hours AS max_hours_per_week,
                'not_ready' as family_fee
        FROM children c,
              child_businesses cb,
              businesses b,
              approvals a,
              child_approvals ca
        LEFT JOIN attendances AT ON at.child_approval_id = ca.id
        AND at.check_in BETWEEN '#{start_date}' AND '#{end_date}'
        WHERE c.id = cb.child_id
          AND cb.business_id = b.id
          AND cb.currently_active = TRUE
          AND b.state = 'NE'
          AND c.id = ca.child_id
          AND ca.approval_id = a.id
          AND a.effective_on <= '#{start_date}'
          AND (a.expires_on >= '#{start_date}'
                OR a.expires_on IS NULL)
        GROUP BY c.id, b.name, a.case_number,
        c.dhs_id, ca.authorized_weekly_hours, a.effective_on, a.expires_on, a.id
        ORDER BY 4,
                  3"
        result = ActiveRecord::Base.connection.exec_query(sql_query)

        # hash_result = render json: result
        hash_result = result.to_json
        parsed_result = JSON.parse(hash_result)
        # binding.pry
        first_approval = find_first_approval(parsed_result, filter_date)
        response_data = {
          as_of: current_user.latest_service_day_in_month(Time.parse(filter_date.to_s).utc) ||
                 Time.current.strftime('%m/%d/%Y'),
          first_approval_effective_date: first_approval,
          data: result
        }
        # binding.pry
        render json: [response_data]
      end

      def find_first_approval(parsed_result, filter_date)
        state = current_user.state
        businesses = current_user.admin ? Business.where(state:) : current_user.businesses
        children = businesses.map(&:children).flatten
        approvals = children.map(&:approvals).flatten
        first_approval_effective_date = approvals.sort_by{ |approval| approval.effective_on }.first.effective_on
        current_user.admin ? first_approval_effective_date : current_user.first_approval_effective_date
      end 
    end
  end
end
