# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SitePolicy do
  subject { described_class }
  let!(:user) { FactoryBot.create(:confirmed_user) }
  let!(:non_owner) { FactoryBot.create(:confirmed_user) }
  let!(:admin) { FactoryBot.create(:admin) }
  let!(:business) { FactoryBot.create(:business, user: user) }
  let!(:site) { FactoryBot.create(:site, business: business) }
  let!(:inactive_site) { FactoryBot.create(:site, name: 'Test Educational Center', business: business, active: false) }
  let(:valid_site) { Site.new(**site.attributes.symbolize_keys.except('id'), name: 'Johnson Elementary School') }

  permissions :create? do
    it 'grants access to admins' do
      expect(subject).to permit(admin, valid_site)
    end

    it 'grants access to owners' do
      expect(subject).to permit(user, valid_site)
    end

    it 'denies access to non-owners' do
      expect(subject).not_to permit(non_owner, valid_site)
    end
  end

  describe SitePolicy::Scope do
    context 'admin user' do
      it 'returns all sites' do
        sites = SitePolicy::Scope.new(admin, Site).resolve
        expect(sites).to match_array([site, inactive_site])
      end
    end

    context 'owner user' do
      it "returns the user's active sites" do
        sites = SitePolicy::Scope.new(user, Site).resolve
        expect(sites).to match_array([site])
      end
    end

    context 'non-owner user' do
      it 'returns an empty relation' do
        sites = SitePolicy::Scope.new(non_owner, Site).resolve
        expect(sites).to be_empty
      end
    end
  end
end
