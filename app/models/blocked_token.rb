# frozen_string_literal: true

# Blocked Tokens for forcing token revokation
class BlockedToken < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Blacklist
end
