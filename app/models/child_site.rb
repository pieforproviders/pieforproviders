# frozen_string_literal: true

# The sites where a child receives care
class ChildSite < ApplicationRecord
  # Handles UUIDs breaking ActiveRecord's usual ".first" and ".last" behavior
  self.implicit_order_column = 'created_at'

  belongs_to :child
  belongs_to :site
end

# == Schema Information
#
# Table name: child_sites
#
#  id       :uuid             not null, primary key
#  child_id :uuid             not null
#  site_id  :uuid             not null
#
