# frozen_string_literal: true

# Blocked Tokens for forcing token revokation
class BlockedToken < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Denylist
end

# == Schema Information
#
# Table name: blocked_tokens
#
#  id         :uuid             not null, primary key
#  expiration :datetime         not null
#  jti        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_blocked_tokens_on_jti  (jti)
#
