# frozen_string_literal: true

# An approval from the state to provide subsidy funding to a family's childcare provider(s)
class Approval < UuidApplicationRecord
  COPAY_FREQUENCIES = %w[daily weekly monthly].freeze

  has_many :child_approvals, dependent: :destroy, inverse_of: :approval, autosave: true
  has_many :children, through: :child_approvals
  has_many :attendances, through: :children
  has_many :illinois_approval_amounts, through: :child_approvals
  has_many :notifications, dependent: :destroy

  accepts_nested_attributes_for :child_approvals, :children

  validates :effective_on, date_param: true, presence: true
  validates :expires_on, date_param: true, unless: proc { |approval| approval.expires_on_before_type_cast.nil? }

  # need to do it this way because postgres/rails enums don't allow for nils
  # and there's a possibility we'll be handling approvals without copays, so
  # in order to preserve data integrity, I don't want to store false info
  enum copay_frequency: Copays.frequencies
  # validates :copay_frequency, inclusion: { in: COPAY_FREQUENCIES, allow_nil: true }

  scope :active, -> { where(active: true) }

  scope :active_on, ->(date) { where(effective_on: ..date).where(expires_on: [date.., nil]).order(updated_at: :desc) }

  scope :with_children, -> { includes(:children) }
  # TODO: needs to change to timestamp and get sent from front-end with timestamps

  monetize :copay_cents, allow_nil: true

  def timezone
    children.first.timezone
  end

  def child_with_most_scheduled_hours(date:)
    return children if children.length == 1

    children.with_schedules.min do |a, b|
      comp = sort_by_scheduled_time(a, b, date)

      if comp.zero?
        sort_by_name(a, b)
      else
        comp
      end
    end
  end

  def sort_by_scheduled_time(sort_a, sort_b, date)
    sort_b.total_time_scheduled_this_month(date:) <=> sort_a.total_time_scheduled_this_month(date:)
  end

  def sort_by_name(sort_a, sort_b)
    sort_a.first_name <=> sort_b.first_name
  end

  def date_in_range?(date)
    date >= effective_on && date <= expires_on
  end
end

# == Schema Information
#
# Table name: approvals
#
#  id              :uuid             not null, primary key
#  active          :boolean          default(TRUE), not null
#  case_number     :string
#  copay_cents     :integer
#  copay_currency  :string           default("USD"), not null
#  copay_frequency :string
#  deleted_at      :date
#  effective_on    :date
#  expires_on      :date
#  inactive_reason :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_approvals_on_effective_on  (effective_on)
#  index_approvals_on_expires_on    (expires_on)
#
