# frozen_string_literal: true

# Association between Users and Children
class UserChild < ApplicationRecord
  belongs_to :user
  belongs_to :child
end

# == Schema Information
#
# Table name: user_children
#
#  id           :uuid             not null, primary key
#  relationship :string
#  child_id     :uuid             not null
#  user_id      :uuid             not null
#
# Indexes
#
#  index_user_children_on_child_id  (child_id)
#  index_user_children_on_user_id   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (child_id => children.id)
#  fk_rails_...  (user_id => users.id)
#
