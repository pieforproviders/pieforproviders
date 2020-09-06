# frozen_string_literal: true

Devise.token_generator.generate(User, :reset_password_token)
