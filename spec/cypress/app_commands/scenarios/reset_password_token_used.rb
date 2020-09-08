# frozen_string_literal: true

user = User.first
user&.update! reset_password_token: nil
