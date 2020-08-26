# frozen_string_literal: true

# The sites where a child receives care
class ChildSite < UuidApplicationRecord
  belongs_to :child
  belongs_to :site

  validates :ended_care, date_param: true, allow_blank: true
  validates :started_care, date_param: true, allow_blank: true
end

# == Schema Information
#
# Table name: child_sites
#
#  id           :uuid             not null, primary key
#  ended_care   :date
#  started_care :date
#  child_id     :uuid             not null
#  site_id      :uuid             not null
#
# Indexes
#
#  index_child_sites_on_child_id_and_site_id  (child_id,site_id)
#
