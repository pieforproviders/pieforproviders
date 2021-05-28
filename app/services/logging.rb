module Logging
  def log(level, message)
    Rails.logger.tagged(self.type.name) { Rails.logger.method(level).call message }
  end
end