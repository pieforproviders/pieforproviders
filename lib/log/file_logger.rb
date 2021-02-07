# frozen_string_literal: true

# custom logger for file output
class Log::FileLogger < ActiveSupport::Logger
  def initialize(*args)
    super(*args)
    # Override formatter but leave it opened to overriding
    @formatter = Log::FileFormatter.new
  end
end
