class BlockedToken < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Blacklist
end