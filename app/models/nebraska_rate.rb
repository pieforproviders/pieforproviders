# frozen_string_literal: true

class NebraskaRate < ApplicationRecord
end

# == Schema Information
#
# Table name: nebraska_rates
#
#  id                                  :uuid             not null, primary key
#  accreditation_enhancement_threshold :decimal(, )      not null
#  county                              :string           not null
#  effective_on                        :date             not null
#  expires_on                          :date
#  license_type                        :string           not null
#  max_age                             :decimal(, )      not null
#  qris_enhancement_threshold          :decimal(, )      not null
#  rate_type                           :string           not null
#  special_needs_enhancement_threshold :decimal(, )      not null
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#
