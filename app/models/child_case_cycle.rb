# frozen_string_literal: true

# The connection between the case cycle and the child
class ChildCaseCycle < UuidApplicationRecord
  belongs_to :user
  belongs_to :child
  belongs_to :subsidy_rule
  belongs_to :case_cycle

  before_save :set_slug

  validates :slug, uniqueness: { case_sensitive: false }
  validates :part_days_allowed, numericality: { greater_than: 0 }
  validates :full_days_allowed, numericality: { greater_than: 0 }

  private

  def set_slug
    self.slug = generate_slug("#{SecureRandom.hex}#{id}")
  end
end

# == Schema Information
#
# Table name: child_case_cycles
#
#  id                :uuid             not null, primary key
#  full_days_allowed :integer          not null
#  part_days_allowed :integer          not null
#  slug              :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  case_cycle_id     :uuid             not null
#  child_id          :uuid             not null
#  subsidy_rule_id   :uuid             not null
#  user_id           :uuid             not null
#
# Indexes
#
#  index_child_case_cycles_on_case_cycle_id    (case_cycle_id)
#  index_child_case_cycles_on_child_id         (child_id)
#  index_child_case_cycles_on_slug             (slug) UNIQUE
#  index_child_case_cycles_on_subsidy_rule_id  (subsidy_rule_id)
#  index_child_case_cycles_on_user_id          (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (case_cycle_id => case_cycles.id)
#  fk_rails_...  (child_id => children.id)
#  fk_rails_...  (subsidy_rule_id => subsidy_rules.id)
#  fk_rails_...  (user_id => users.id)
#
