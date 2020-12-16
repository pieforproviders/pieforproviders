# frozen_string_literal: true

# A child in care at businesses who need subsidy assistance
class Child < UuidApplicationRecord
  belongs_to :user
  has_many :child_sites, dependent: :destroy
  has_many :sites, through: :child_sites

  validates :active, inclusion: { in: [true, false] }
  validates :date_of_birth, presence: true
  validates :full_name, presence: true
  validates :full_name, uniqueness: { scope: %i[date_of_birth user_id] }

  validates :date_of_birth, date_param: true

  accepts_nested_attributes_for :child_sites
end

# == Schema Information
#
# Table name: children
#
#  id            :uuid             not null, primary key
#  active        :boolean          default(TRUE), not null
#  date_of_birth :date             not null
#  full_name     :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  ccms_id       :string
#  user_id       :uuid             not null
#
# Indexes
#
#  index_children_on_user_id  (user_id)
#  unique_children            (full_name,date_of_birth,user_id) UNIQUE
#
