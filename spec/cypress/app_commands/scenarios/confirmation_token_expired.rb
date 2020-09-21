# frozen_string_literal: true

user = User.first
user&.update! confirmation_sent_at: 4.days.ago
