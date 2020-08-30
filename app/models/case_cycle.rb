# frozen_string_literal: true

# The cycle for subsidy cases
class CaseCycle < UuidApplicationRecord
  STATUSES = %w[submitted pending approved denied].freeze
  COPAY_FREQUENCIES = %w[daily weekly monthly].freeze

  monetize :copay_cents

  enum status: STATUSES.to_h { |s| [s, s] }
  enum copay_frequency: COPAY_FREQUENCIES.to_h { |f| [f, f] }, _suffix: true

  before_save :set_slug

  validates :slug, uniqueness: true
  validates :copay, numericality: { greater_than: 0 }
  validates :submitted_on, date_param: true, allow_blank: true
  validates :effective_on, date_param: true, allow_blank: true
  validates :expires_on, date_param: true, allow_blank: true
  validates :notified_on, date_param: true, allow_blank: true

  private

  def set_slug
    self.slug = generate_slug("#{case_number.presence || SecureRandom.hex}#{id}")
  end
end

# == Schema Information
#
# Table name: case_cycles
#
#  id              :uuid             not null, primary key
#  case_number     :string
#  copay_cents     :integer          default(0), not null
#  copay_currency  :string           default("USD"), not null
#  copay_frequency :enum             not null
#  effective_on    :date
#  expires_on      :date
#  notified_on     :date
#  slug            :string           not null
#  status          :enum             default("submitted"), not null
#  submitted_on    :date             not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_case_cycles_on_slug  (slug) UNIQUE
#
