# frozen_string_literal: true

user = User.first
user&.update! confirmed_at: Time.current
