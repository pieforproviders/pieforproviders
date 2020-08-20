# frozen_string_literal: true

# Blocked Tokens for forcing token revokation
class BlockedToken < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Blacklist
end

# == Schema Information
#
# Table name: blocked_tokens
#
#  id         :bigint           not null, primary key
#  expiration :datetime         not null
#  jti        :string           not null
#
# Indexes
#
#  index_blocked_tokens_on_jti  (jti)
#
