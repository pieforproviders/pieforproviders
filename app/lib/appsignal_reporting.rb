# frozen_string_literal: true

# Appsignal Reporting wrapper
module AppsignalReporting
  def send_appsignal_error(action:, exception:, namespace: nil, metadata: nil)
    Appsignal.send_error(exception) do |transaction|
      transaction.set_action(action)
      transaction.set_namespace(namespace) if namespace
      transaction.params = { time: Time.current.to_s }.merge(metadata)
    end
  end
end
