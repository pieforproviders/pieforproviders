# frozen_string_literal: true

GoodJob.on_thread_error = ->(exception) { Raven.capture_exception(exception) } if Rails.env.production?
