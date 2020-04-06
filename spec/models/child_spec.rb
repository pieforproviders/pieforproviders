# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Child, type: :model do
  it { should belong_to(:user) }
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:full_name) }
  it { should validate_presence_of(:last_name) }
  it { should validate_presence_of(:date_of_birth) }
end
