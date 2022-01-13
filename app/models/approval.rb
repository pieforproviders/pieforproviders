# frozen_string_literal: true

# An approval from the state to provide subsidy funding to a family's childcare provider(s)
class Approval < UuidApplicationRecord
  COPAY_FREQUENCIES = %w[daily weekly monthly].freeze

  has_many :child_approvals, dependent: :destroy, inverse_of: :approval, autosave: true
  has_many :children, through: :child_approvals
  has_many :illinois_approval_amounts, through: :child_approvals

  accepts_nested_attributes_for :child_approvals, :children

  validates :effective_on, date_param: true, presence: true
  validates :expires_on, date_param: true, unless: proc { |approval| approval.expires_on_before_type_cast.nil? }

  # need to do it this way because postgres/rails enums don't allow for nils
  # and there's a possibility we'll be handling approvals without copays, so
  # in order to preserve data integrity, I don't want to store false info
  enum copay_frequency: Copays.frequencies
  # validates :copay_frequency, inclusion: { in: COPAY_FREQUENCIES, allow_nil: true }

  scope :active, -> { where(active: true) }
  scope :active_on,
        lambda { |date|
          where('effective_on <= ? and (expires_on is null or expires_on > ?)', date, date).order(updated_at: :desc)
        }

  monetize :copay_cents, allow_nil: true

  def timezone
    children.first.timezone
  end

  def child_with_most_scheduled_hours(date:)
    children.sort do |a, b|
      if (b.total_time_scheduled_this_month(date: date) <=> a.total_time_scheduled_this_month(date: date)) == 0
        a.full_name <=> b.full_name
      else
        b.total_time_scheduled_this_month(date: date) <=> a.total_time_scheduled_this_month(date: date)
      end
    end.first
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
