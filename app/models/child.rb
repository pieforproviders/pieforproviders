# frozen_string_literal: true

# A child in care at businesses who need subsidy assistance
class Child < UuidApplicationRecord
  before_save :find_or_create_approvals
  after_commit :associate_subsidy_rule, unless: proc { |child| child.deleted || child.active_previously_changed?(from: true, to: false) }

  belongs_to :business

  has_many :child_approvals, dependent: :destroy, inverse_of: :child, autosave: true
  has_many :approvals, through: :child_approvals

  has_one :temporary_nebraska_dashboard_case, dependent: :destroy

  validates :approvals, presence: true
  validates :date_of_birth, date_param: true
  validates :date_of_birth, presence: true
  validates :full_name, presence: true
  # This prevents this validation from running if other validations failed; if date_of_birth has thrown an error,
  # this will try to validate with the incorrect dob even though the record has already failed
  validates :full_name, uniqueness: { scope: %i[date_of_birth business_id] }, unless: -> { errors }

  REASONS = %w[
    no_longer_in_my_care
    no_longer_recieving_subsidies
    other
  ].freeze
  validates :inactive_reason, inclusion: { in: REASONS }, allow_nil: true
  validates :last_active_date, date_param: true, allow_nil: true

  accepts_nested_attributes_for :approvals, :child_approvals

  scope :active, -> { where(active: true) }
  scope :approved_for_date, ->(date) { joins(:approvals).merge(Approval.active_on_date(date)) }
  scope :not_deleted, -> { where(deleted: false) }

  delegate :user, to: :business
  delegate :state, to: :user
  delegate :timezone, to: :user

  def active_approval(date)
    approvals.active_on_date(date).first
  end

  def active_child_approval(date)
    active_approval(date).child_approvals.find_by(child: self)
  end

  def attendances
    Attendance.joins(:child_approval).where(child_approvals: { child: self })
  end

  def attendance_rate(filter_date)
    AttendanceRateCalculator.new(self, filter_date).call
  end

  def attendance_risk(filter_date)
    AttendanceRiskCalculator.new(self, filter_date).call
  end

  def active_subsidy_rule(date)
    active_child_approval(date).subsidy_rule
  end

  def illinois_approval_amounts
    IllinoisApprovalAmount.where(child_approval: ChildApproval.where(child: self))
  end

  private

  def find_or_create_approvals
    self.approvals = approvals.map do |approval|
      Approval.find_or_create_by(case_number: approval.case_number,
                                 effective_on: approval.effective_on,
                                 expires_on: approval.expires_on)
    end
  end

  def associate_subsidy_rule
    SubsidyRuleAssociatorJob.perform_later(id)
  end
end

# == Schema Information
#
# Table name: children
#
#  id                 :uuid             not null, primary key
#  active             :boolean          default(TRUE), not null
#  date_of_birth      :date             not null
#  enrolled_in_school :boolean
#  full_name          :string           not null
#  inactive_reason    :string
#  last_active_date   :date
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  business_id        :uuid             not null
#  dhs_id             :string
#  wonderschool_id    :string
#
# Indexes
#
#  index_children_on_business_id  (business_id)
#  unique_children                (full_name,date_of_birth,business_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (business_id => businesses.id)
#
