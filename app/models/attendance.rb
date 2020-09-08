# frozen_string_literal: true

# Attendance of a child during a specific cycle for a child case
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
