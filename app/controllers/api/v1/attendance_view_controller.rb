# frozen_string_literal: true

# rubocop: disable Metrics/AbcSize
# rubocop: disable Metrics/LineLength
module Api
  module V1
    # Service for dashboard table info
    class AttendanceViewController < ApiController
      def index
        filter_date = params[:filter_date].to_date
        current_date = Date.current
        start_date = filter_date == current_date ? (current_date.at_beginning_of_week - 1.day).to_s : filter_date.to_s
        end_date = filter_date == current_date ? current_date.at_end_of_week.to_s : (filter_date + 1.day).at_end_of_week.to_s
        business_condition = ''
        business_ids = params[:business_ids]
        business_condition = ' AND b.id IN (?) ' if business_ids.present?

        query_conditions = [attendances_query(business_condition),
                            end_date,
                            start_date,
                            start_date,
                            end_date]

        query_conditions << business_ids if business_ids.present?

        query_response = ActiveRecord::Base.connection.execute(ActiveRecord::Base.sanitize_sql_for_conditions(query_conditions))
        
        binding.pry
        
        result = query_response.map { |data| data }
        result.each do |item|
          item['attendances'] = JSON.parse(item['attendances'])
          tags = ServiceDay.find(item['id']).tags
          item['tags'] = tags
          item['child'] = JSON.parse(item['child'])
        end
        render json: result
      end

      def attendances_query(business_condition = '')
        <<-SQL.squish
        SELECT
        sd.id,
        sd.absence_type,
        sd.date,
        sd.full_time,
        sd.part_time,
        b.state,
        EXTRACT(EPOCH FROM total_time_in_care) AS total_time_in_care,
        COALESCE(json_agg(json_build_object(
          'id', a.id,
          'check_in', a.check_in,
          'check_out', a.check_out,
          'child_approval_id', a.child_approval_id,
          'time_in_care', a.time_in_care
        ) ORDER BY a.check_in) FILTER (WHERE a.id IS NOT NULL), '[]') AS attendances,
        json_build_object(
          'id', c.id,
          'active', c.active,
          'active_business', json_build_object(
            'id', b.id,
            'name', b.name
          ),
          'business_name', b.name,
          'first_name', c.first_name,
          'inactive_reason', c.inactive_reason,
          'last_active_date', c.last_active_date,
          'last_inactive_date', c.last_inactive_date,
          'last_name', c.last_name,
          'wonderschool_id', c.wonderschool_id
        ) AS child
      FROM
        service_days sd
      LEFT JOIN attendances a ON sd.id = a.service_day_id
      LEFT JOIN child_approvals ca ON a.child_approval_id = ca.id
      JOIN approvals app ON ca.approval_id = app.id AND app.effective_on <= ? AND (app.expires_on IS NULL OR app.expires_on >= ?)
      LEFT JOIN children c ON ca.child_id = c.id
      LEFT JOIN child_businesses cb ON c.id = cb.child_id
      LEFT JOIN businesses b ON cb.business_id = b.id AND b.active
      WHERE
        sd.date BETWEEN ? AND ?
        #{business_condition}
        GROUP BY sd.id, c.id, b.id, b.state
      ORDER BY sd.date, c.last_name, c.first_name;
        SQL
      end
    end
  end
end
# rubocop: enable Metrics/AbcSize
# rubocop: enable Metrics/LineLength
