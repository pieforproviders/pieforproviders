# frozen_string_literal: true

# Period in which a child shouldn't be marked as absent.
class NotAttendingPeriod < ApplicationRecord
  belongs_to :child

  validates :start_date, :end_date, presence: true

  validate :end_date_after_start_date

  scope :currently_active, -> { where('start_date <= ? AND end_date >= ?', Date.today, Date.today) } # rubocop:disable Rails/Date

  def active?
    start_date <= Date.today && end_date >= Date.today # rubocop:disable Rails/Date
  end

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    return unless end_date < start_date

    errors.add(:end_date, 'must be after the start date')
  end
end

# == Schema Information
#
# Table name: not_attending_periods
#
#  id         :uuid             not null, primary key
#  end_date   :date
#  start_date :date
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  child_id   :uuid             not null
#
# Indexes
#
#  index_not_attending_periods_on_child_id  (child_id)
#
# Foreign Keys
#
#  fk_rails_...  (child_id => children.id)
#
