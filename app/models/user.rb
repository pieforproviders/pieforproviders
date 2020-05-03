# frozen_string_literal: true

# Person responsible for subsidy management for one or more businesses
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :confirmable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: BlockedToken
  # Handles UUIDs breaking ActiveRecord's usual ".first" and ".last" behavior
  self.implicit_order_column = 'created_at'

  has_many :businesses, dependent: :restrict_with_error
  has_many :children, dependent: :restrict_with_error

  validates :active, inclusion: { in: [true, false] }
  validates :email, presence: true, uniqueness: true
  validates :full_name, presence: true
  validates :language, presence: true
  validates :organization, presence: true
  validates :opt_in_email, inclusion: { in: [true, false] }
  validates :opt_in_phone, inclusion: { in: [true, false] }
  validates :opt_in_text, inclusion: { in: [true, false] }
  validates :service_agreement_accepted, inclusion: { in: [true, false] }
  validates :timezone, presence: true

  scope :active, -> { where(active: true) }

  before_validation { |user| user.slug = generate_slug(user.email) }

  # format phone numbers - remove any non-digit characters
  def phone=(value)
    super(value.blank? ? nil : value.gsub(/[^\d]/, ''))
  end
end

# == Schema Information
#
# Table name: users
#
#  id                         :uuid             not null, primary key
#  active                     :boolean          default(TRUE), not null
#  email                      :string           not null
#  full_name                  :string           not null
#  greeting_name              :string
#  language                   :string           not null
#  mobile                     :string
#  opt_in_email               :boolean          default(TRUE), not null
#  opt_in_phone               :boolean          default(TRUE), not null
#  opt_in_text                :boolean          default(TRUE), not null
#  organization               :string           not null
#  phone                      :string
#  service_agreement_accepted :boolean          default(FALSE), not null
#  slug                       :string           not null
#  timezone                   :string           not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#  index_users_on_slug   (slug) UNIQUE
#
