# frozen_string_literal: true

class FetchBusinessCases
  def self.call(business_id, filter_date)
    new(business_id, filter_date).call
  end

  attr_reader :filter_date, :business_id

  def initialize(business_id, filter_date)
    @filter_date = filter_date
    @business_id = business_id
  end

  def call
    result = execute.map { |row| row }

    result.first
  end

  private

  def query
    <<~SQL.squish
      SELECT
        'unset' AS as_of,
        'unset' AS first_approval_effective_date,
        'unset' AS max_revenue,
        'unset' AS total_approved,
        biz.name AS buisness_name,

        ch.id AS case_id,
        ch.active AS case_active,
        'unset' AS case_number,
        ch.full_name AS case_full_name,
        'unset' AS case_family_fee,
        ch.inactive_reason AS case_inactive_reason,
        ch.last_active_date AS case_last_active_date,

        'unset' AS case_attendance_risk,
        'unset' AS case_attendance_full_days,
        'unset' AS case_attendance_absences,
        5 AS case_attendance_max_absences,
        'unset' AS case_attendance_week_hours,
        'unset' AS case_attendance_max_week_hours,

        'unset' AS case_revenue_earned,
        'unset' AS case_revenue_estimated,

        oap.expires_on AS case_approval_expires_on,
        oap.effective_on AS case_approval_effective_on,
        'unset' AS case_approval_hours_remaining,
        'unset' AS case_approval_hours_authorized,
        'unset' AS case_approval_full_days_remaining,
        'unset' AS case_approval_full_days_authorized
    FROM businesses AS biz
    LEFT JOIN children AS ch ON ch.business_id = biz.id AND ch.deleted_at IS NULL
    LEFT JOIN (
      SELECT
        cap.child_id,
        ap.expires_on,
        ap.effective_on
      FROM child_approvals cap
      INNER JOIN approvals ap ON ap.id = cap.approval_id AND ap.effective_on <= '2022-03-02' AND (
        ap.expires_on IS NULL
        OR ap.expires_on > '2022-03-02'
      )
    ) AS oap ON oap.child_id = ch.id
    WHERE biz.id = '03a221a6-32a4-44dd-b32e-3162813ab061'
  
    SQL
  end

  def execute
    ActiveRecord::Base.connection.exec_query(query, self.class.name)
  end
end

module Api
  module V1
    class CasesController < Api::V1::ApiController
      def index
        result = FetchBusinessCases.call(params[:id], params[:filter_date])

        return render json: { data: result }
      end
    end
  end
end
