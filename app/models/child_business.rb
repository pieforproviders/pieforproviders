# frozen_string_literal: true

# ChildBusiness model lets children have multiple businesses
class ChildBusiness < ApplicationRecord
  belongs_to :child
  belongs_to :business

  # validates :currently_active,
  #           uniqueness: { scope: :child_id, message: I18n.t('errors.messages.one_business_only') },
  #           if: :currently_active

  # validates :business_id, uniqueness: { scope: :child_id }
end

# == Schema Information
#
# Table name: child_businesses
#
#  id               :uuid             not null, primary key
#  currently_active :boolean          default(FALSE)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  business_id      :uuid             not null
#  child_id         :uuid             not null
#
# Indexes
#
#  index_child_businesses_on_business_id  (business_id)
#  index_child_businesses_on_child_id     (child_id)
#
# Foreign Keys
#
#  fk_rails_...  (business_id => businesses.id)
#  fk_rails_...  (child_id => children.id)
#
