require 'rails_helper'
include FeatureMacros
i_need_ldap

RSpec.feature 'Dashboard Layout Changes' do
  let(:user) { create(:ldap_user) }

  before(:each) do
    sign_in(user)
  end

  scenario 'dashboard sidebar shouldnt display tasks' do
    user.add_role('admin') #Tasks only show to admin anyway
    visit hyrax.dashboard_path

    sidebar = find('.sidebar')
    expect(sidebar).not_to have_content('Tasks')
    expect(sidebar).not_to have_content('Review Submissions')
    expect(sidebar).not_to have_content('Manage Embargoes')
    expect(sidebar).not_to have_content('Manage Leases')
  end

  scenario 'dashboard sidebar should only display works option to admin' do
    visit hyrax.dashboard_path
    expect(find('.sidebar')).not_to have_content('Works')

    user.add_role('admin')
    visit hyrax.dashboard_path
    expect(find('.sidebar')).to have_content('Works')
  end
end