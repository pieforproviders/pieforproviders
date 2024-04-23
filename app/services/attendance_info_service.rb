# frozen_string_literal: true

# Service to retrieve attendance info for attendance view page

# rubocop: disable Metrics/AbcSize
# rubocop: disable Metrics/LineLength
# rubocop: disable Style/OpenStructUse
# rubocop: disable Lint/SymbolConversion
class AttendanceInfoService
  def initialize(start_date, end_date, business_ids)
    @start_date = start_date
    @end_date = end_date
    @business_ids = business_ids
  end

  def call
    build_attendance_info
  end

  def build_attendance_info
    business_condition = ''
    business_condition = ' AND b.id IN (?) ' if @business_ids.present?

    query_conditions = [attendances_query(business_condition), @end_date, @start_date, @start_date, @end_date]

    query_conditions << @business_ids if @business_ids.present?

    query_response = ActiveRecord::Base.connection.execute(ActiveRecord::Base.sanitize_sql_for_conditions(query_conditions))

    build_data(query_response)
  end

  def build_data(query_response)
    result = query_response.map { |data| data }
    result.each do |item|
      item['attendances'] = JSON.parse(item['attendances'])
      service_day_info = OpenStruct.new({ total_time_in_care: item['total_time_in_care'].to_i.seconds, state: item['state'], 'absence?': item['absence_type'].present? })
      tags_calculator = Nebraska::TagsCalculator.new(service_day: service_day_info)
      tags = tags_calculator.call
      item['tags'] = tags
      item['child'] = JSON.parse(item['child'])
    end
    result
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
      EXTRACT(EPOCH FROM sd.total_time_in_care) AS total_time_in_care,
      COALESCE(json_agg(
          json_build_object(
              'id', a.id,
              'check_in', a.check_in,
              'check_out', a.check_out,
              'child_approval_id', a.child_approval_id,
              'time_in_care', a.time_in_care
          ) ORDER BY a.check_in
      ) FILTER (WHERE a.id IS NOT NULL), '[]') AS attendances,
      json_build_object(
          'id', c.id,
          'active', COALESCE(c.active, false),
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
      LEFT JOIN child_approvals ca ON sd.child_id = ca.child_id
      JOIN approvals app ON ca.approval_id = app.id
            AND app.effective_on <= ?
            AND (app.expires_on IS NULL OR app.expires_on >= ?)
      LEFT JOIN children c ON sd.child_id = c.id
      LEFT JOIN child_businesses cb ON c.id = cb.child_id
      LEFT JOIN businesses b ON cb.business_id = b.id AND b.active
      WHERE
          sd.date BETWEEN ? AND ?
          #{business_condition}
      GROUP BY
          sd.id, c.id, b.id, b.state
      ORDER BY
          sd.date, c.last_name, c.first_name;
    SQL
  end
end
# rubocop: enable Metrics/AbcSize
# rubocop: enable Metrics/LineLength
# rubocop: enable Style/OpenStructUse
# rubocop: enable Lint/SymbolConversion
