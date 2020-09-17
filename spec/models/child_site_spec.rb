# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChildSite, type: :model do
  it { should belong_to(:child) }
  it { should belong_to(:site) }

  # TODO: validate started_care, ended_care
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
