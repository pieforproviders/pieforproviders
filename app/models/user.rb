# frozen_string_literal: true

# Person responsible for subsidy management for one or more businesses
class User < UuidApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :omniauthable, :rememberable, :timeoutable, :trackable
  devise :confirmable, :database_authenticatable, :registerable,
         :recoverable, :validatable, :jwt_authenticatable,
         jwt_revocation_strategy: BlockedToken

  has_many :businesses, dependent: :restrict_with_error

  validates :active, inclusion: { in: [true, false] }
  validates :email, presence: true, uniqueness: true
  validates :full_name, presence: true
  validates :greeting_name, presence: true
  validates :language, presence: true
  validates :organization, presence: true
  validates :opt_in_email, inclusion: { in: [true, false] }
  validates :opt_in_text, inclusion: { in: [true, false] }
  validates :phone_number, uniqueness: true, allow_nil: true
  validates :service_agreement_accepted, presence: true
  validates :timezone, presence: true

  scope :active, -> { where(active: true) }

  # format phone numbers - remove any non-digit characters
  def phone_number=(value)
    super(value.blank? ? nil : value.gsub(/[^\d]/, ''))
  end

  def as_json(_options = {})
    super(except: [:admin])
  end
end

# == Schema Information
#
# Table name: users
#
#  id                         :uuid             not null, primary key
#  active                     :boolean          default(TRUE), not null
#  admin                      :boolean          default(FALSE), not null
#  confirmation_sent_at       :datetime
#  confirmation_token         :string
#  confirmed_at               :datetime
#  current_sign_in_at         :datetime
#  current_sign_in_ip         :inet
#  email                      :string           not null
#  encrypted_password         :string           default(""), not null
#  failed_attempts            :integer          default(0), not null
#  full_name                  :string           not null
#  greeting_name              :string           not null
#  language                   :string           not null
#  last_sign_in_at            :datetime
#  last_sign_in_ip            :inet
#  locked_at                  :datetime
#  opt_in_email               :boolean          default(TRUE), not null
#  opt_in_text                :boolean          default(TRUE), not null
#  organization               :string           not null
#  phone_number               :string
#  phone_type                 :string
#  remember_created_at        :datetime
#  reset_password_sent_at     :datetime
#  reset_password_token       :string
#  service_agreement_accepted :boolean          default(FALSE), not null
#  sign_in_count              :integer          default(0), not null
#  timezone                   :string           not null
#  unconfirmed_email          :string
#  unlock_token               :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_phone_number          (phone_number) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_unlock_token          (unlock_token) UNIQUE
#
