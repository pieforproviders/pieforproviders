# frozen_string_literal: true

# rubocop: disable Metrics/AbcSize
# rubocop: disable Metrics/LineLength
module Api
  module V1
    # Service for dashboard table info
    class DashboardCaseController < ApiController
      def index
        filter_date = params[:filter_date].present? ? params[:filter_date].to_date : Date.current
        start_date = filter_date.at_beginning_of_month.to_s
        end_date = filter_date.at_end_of_month.to_s

        all_business_ids = Business.all.map { |business| business.id.to_s }
        selected_business_ids = params[:business]&.split(',')

        filter_business_ids = params[:business].present? ? selected_business_ids : all_business_ids

        result = ActiveRecord::Base.connection.execute(ActiveRecord::Base.sanitize_sql_for_conditions([
                                                                                                        dashboard_query,
                                                                                                        start_date,
                                                                                                        end_date,
                                                                                                        start_date,
                                                                                                        end_date,
                                                                                                        start_date,
                                                                                                        end_date,
                                                                                                        start_date,
                                                                                                        end_date,
                                                                                                        end_date,
                                                                                                        end_date,
                                                                                                        start_date,
                                                                                                        end_date,
                                                                                                        filter_business_ids,
                                                                                                        end_date,
                                                                                                        end_date
                                                                                                      ]))
        first_approval = find_first_approval
        response_data = {
          as_of: current_user.latest_service_day_in_month(Time.parse(filter_date.to_s).utc) ||
                 Time.current.strftime('%m/%d/%Y'),
          first_approval_effective_date: first_approval,
          data: result
        }
        render json: [response_data]
      end

      def dashboard_query
        <<-SQL.squish
            SELECT c.id,
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
                          AND date BETWEEN ? AND ?), 0) AS part_time,
            coalesce(
                      (SELECT sum(sd.full_time)
                        FROM service_days sd
                        WHERE sd.child_id = c.id
                          AND sd.absence_type IS NULL
                          AND date BETWEEN ? AND ?), 0) AS full_time,
            coalesce(
                      (SELECT count(sd.id)
                        FROM service_days sd
                        WHERE sd.child_id = c.id
                          AND sd.absence_type IS NOT NULL
                          AND date BETWEEN ? AND ?), 0) AS absences_count,

      (SELECT STRING_AGG(service_date, ', ')
        FROM
          (SELECT TO_CHAR(date, 'MM/dd') AS service_date
          FROM service_days sd
          WHERE sd.child_id = c.id
            AND sd.absence_type IS NOT NULL
            AND date BETWEEN ? AND ?
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
                          WHERE naa.effective_on <= ?
                            AND (naa.expires_on >= ?
                                  OR naa.expires_on IS NULL)
                            AND ca.child_id = c.id ) AS subquery
                        WHERE rn = 1), 0) AS family_fee
              FROM children c,
                    child_businesses cb,
                    businesses b,
                    approvals a,
                    child_approvals ca
              LEFT JOIN attendances AT ON at.child_approval_id = ca.id
              AND at.check_in BETWEEN ? AND ?
              WHERE c.id = cb.child_id
                AND cb.business_id = b.id
                AND cb.currently_active = TRUE
                AND b.state = 'NE'
                AND b.id IN (?)
                AND c.id = ca.child_id
                AND ca.approval_id = a.id
                AND a.effective_on <= ?
                AND (a.expires_on >= ?
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
                        3
        SQL
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
# rubocop: enable Metrics/LineLength
