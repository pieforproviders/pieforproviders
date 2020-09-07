# frozen_string_literal: true

# The businesses for which users are responsible for keeping subsidy data
class Business < UuidApplicationRecord
  belongs_to :user

  enum license_type: Licenses.types

  validates :active, inclusion: { in: [true, false] }
  validates :name, presence: true, uniqueness: { scope: :user_id }

  before_validation { |business| business.slug = generate_slug("#{business.name}#{business.user_id}") }
end

# == Schema Information
#
# Table name: businesses
#
#  id           :uuid             not null, primary key
#  active       :boolean          default(TRUE), not null
#  license_type :enum
#  name         :string           not null
#  slug         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :uuid             not null
#
# Indexes
#
#  index_businesses_on_name_and_user_id  (name,user_id) UNIQUE
#  index_businesses_on_slug              (slug) UNIQUE
#  index_businesses_on_user_id           (user_id)
#
