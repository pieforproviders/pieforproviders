# frozen_string_literal: true

# Appsignal Reporting wrapper
module AppsignalReporting
  def send_appsignal_error(action, message, identifier = nil)
    Appsignal.send_error(message) do |transaction|
      transaction.set_action(action)
      transaction.params = { time: Time.current.to_s, identifier: identifier }
    end
  end
end
