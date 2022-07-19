# frozen_string_literal: true

# Appsignal Reporting wrapper
module AppsignalReporting
  def send_appsignal_error(action:, exception:, namespace: nil, tags: nil)
    Appsignal.send_error(exception) do |transaction|
      transaction.set_tags(tags) if tags
      transaction.set_action(action)
      transaction.set_namespace(namespace) if namespace
    end
    # TODO: catch an appsignal exception and.............?  mail it to myself?  :shrug:
  end
end
