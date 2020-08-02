# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChildSite, type: :model do
  it { should belong_to(:child) }
  it { should belong_to(:site) }
end

# == Schema Information
#
# Table name: child_sites
#
#  id       :uuid             not null, primary key
#  child_id :uuid             not null
#  site_id  :uuid             not null
#
