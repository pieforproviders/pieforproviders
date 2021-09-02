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

  scope :active_on_date, ->(date) { where('effective_on <= ? and (expires_on is null or expires_on > ?)', date, date).order(updated_at: :desc) }

  monetize :copay_cents, allow_nil: true

  def timezone
    children.first.timezone
  end

  def child_with_most_scheduled_hours(filter_date)
    children.max_by { |child| child.total_time_scheduled_this_month(filter_date) }
  end
end

# == Schema Information
#
# Table name: approvals
#
#  id              :uuid             not null, primary key
#  case_number     :string
#  copay_cents     :integer
#  copay_currency  :string           default("USD"), not null
#  copay_frequency :string
#  effective_on    :date
#  expires_on      :date
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
