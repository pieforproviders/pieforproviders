# frozen_string_literal: true

# Concerns related to batch controllers
module Batchable
  def self.add_error_and_return_nil(key, errors, message = "can't be blank")
    errors[key] += [message]
    nil
  end

  def self.child_approval_id(child_id, date, errors, message)
    Child.find(child_id)
      &.active_child_approval(Date.parse(date))
      &.id || add_error_and_return_nil(
        :child_approval_id,
        errors,
        message
      )
  end
end
