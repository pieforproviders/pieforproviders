# frozen_string_literal: true

# rubocop: disable Metrics/AbcSize
# rubocop: disable Metrics/ClassLength
# rubocop: disable Metrics/CyclomaticComplexity
# rubocop: disable Metrics/MethodLength
module Api
  module V1
    # Service for dashboard table info
    class DashboardCaseController < ApiController
      def index
        filter_date = params[:filter_date].present? ? params[:filter_date].to_date : Date.current
        start_date = filter_date.at_beginning_of_month.to_s
        end_date = filter_date.at_end_of_month.to_s

        business_ids = params[:business].present? ? params[:business].split(',') : nil
        formatted_business_ids = business_ids&.map { |business_id| "'#{business_id}'" }&.join(',')

        business_ids_filter = business_ids.present? ? "AND b.id IN (#{formatted_business_ids})" : ''

        sql_query = "SELECT c.id,
        c.active,
        c.first_name,
        c.last_name,
        b.name AS business_name,
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
                      AND sd.absence_type IS NOT NULL
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
        coalesce(
                   (SELECT family_fee
                    FROM
                      (SELECT
                        child_id,
                        family_fee,
                        child_approval_id,
                        a.effective_on,
                        a.expires_on,
                        ROW_NUMBER() OVER (
                          PARTITION BY child_id
                          ORDER BY
                            a.expires_on DESC NULLS LAST
                        ) AS rn
                       FROM nebraska_approval_amounts naa
                       JOIN child_approvals ca ON naa.child_approval_id = ca.id
                       JOIN approvals a ON ca.approval_id = a.id
                       WHERE naa.effective_on <= '#{end_date}'
                         AND (naa.expires_on >= '#{end_date}'
                              OR naa.expires_on IS NULL)
                         AND ca.child_id = c.id ) AS subquery
                    WHERE rn = 1), 0) AS family_fee
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
            #{business_ids_filter}
            AND c.id = ca.child_id
            AND ca.approval_id = a.id
            AND a.effective_on <= '#{end_date}'
            AND (a.expires_on >= '#{end_date}'
                  OR a.expires_on IS NULL)
          GROUP BY c.id,
                    b.name,
                    a.case_number,
                    c.dhs_id,
                    ca.authorized_weekly_hours,
                    a.effective_on,
                    a.expires_on,
                    a.id
          ORDER BY 4,
                    3"
        result = ActiveRecord::Base.connection.exec_query(sql_query)
        first_approval = find_first_approval
        response_data = {
          as_of: current_user.latest_service_day_in_month(Time.parse(filter_date.to_s).utc) ||
                 Time.current.strftime('%m/%d/%Y'),
          first_approval_effective_date: first_approval,
          data: result
        }
        render json: [response_data]
      end

      def find_first_approval
        businesses = current_user.admin ? Business.where(state: current_user.state) : current_user.businesses
        children = businesses.map(&:children).flatten
        approvals = children.map(&:approvals).flatten
        first_approval_effective_date = check_approvals(approvals)
        current_user.admin ? first_approval_effective_date : current_user.first_approval_effective_date
      end

      def check_approvals(approvals)
        approvals.min_by(&:effective_on).effective_on
      end
    end
  end
end
# rubocop: enable Metrics/AbcSize
# rubocop: enable Metrics/ClassLength
# rubocop: enable Metrics/CyclomaticComplexity
# rubocop: enable Metrics/MethodLength
