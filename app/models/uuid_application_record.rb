# frozen_string_literal: true

# Superclass for all ActiveRecords using UUIDs.
# Fix so ActiveRecord's usual ".first" and ".last" behavior works with UUIDs.
class UuidApplicationRecord < ApplicationRecord
  self.abstract_class = true

  self.implicit_order_column = 'created_at'
end
