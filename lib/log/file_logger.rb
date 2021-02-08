# frozen_string_literal: true

module Log
  # custom logger for file output
  class FileLogger < ActiveSupport::Logger
    def initialize(*args)
      super(*args)
      # Override formatter but leave it opened to overriding
      @formatter = Log::FileFormatter.new
    end
  end
end
