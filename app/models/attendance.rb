# frozen_string_literal: true

# Attendance of a child during a specific cycle for a child case
#
# from GitHub comments on the PR to implement this model (PR 320)
# 2020-09-08: open question from Kate D.:
#   When someone adds an attendance, are we expecting them to choose what
#   length of care it is, or are we calculating that by the number of hours
#   as laid out in their subsidy rule?
#   If we're calculating it, can the user change it, if for some reason our
#   calculation gets it wrong?
#
#   2020-09-08: Answer from Chelsea S:
#   Since we haven't designed these screens yet, I don't think we have clear
#   answers. My assumption, though, is that we're calculating it for them based
#   on the number of hours, as laid out in their subsidy rule.
#   I'm not sure if we'll let them change it.
#
class Attendance < UuidApplicationRecord
  belongs_to :child_case_cycle

  LENGTHS_OF_CARE = %w[part_day full_day full_plus_part_day full_plus_full_day].freeze
  enum length_of_care: LENGTHS_OF_CARE.index_by(&:to_sym)

  before_save :set_slug

  validates :slug, uniqueness: true
  validates :starts_on, date_param: true

  private

  def set_slug
    self.slug = generate_slug("#{SecureRandom.hex}#{id}")
  end
end

# == Schema Information
#
# Table name: attendances
#
#  id                  :uuid             not null, primary key
#  length_of_care      :enum             default("full_day"), not null
#  slug                :string           not null
#  starts_on           :date             not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  child_case_cycle_id :uuid             not null
#
# Indexes
#
#  index_attendances_on_child_case_cycle_id  (child_case_cycle_id)
#  index_attendances_on_slug                 (slug) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (child_case_cycle_id => child_case_cycles.id)
#
