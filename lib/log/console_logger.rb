# frozen_string_literal: true

module Log
  # custom logger for console output
  class ConsoleLogger < ActiveSupport::Logger
    def initialize(*args)
      super(*args)
      # Override formatter but leave it opened to overriding
      @formatter = Log::ConsoleFormatter.new
    end
  end
end
