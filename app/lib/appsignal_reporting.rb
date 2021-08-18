# frozen_string_literal: true

# Appsignal Reporting wrapper
module AppsignalReporting
  def send_appsignal_error(action, exception, identifier = nil)
    Appsignal.send_error(exception) do |transaction|
      transaction.set_action(action)
      transaction.params = { time: Time.current.to_s, identifier: identifier }
    end
  end
end
