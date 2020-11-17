require 'rails_helper'
include FeatureMacros
i_need_ldap

RSpec.feature 'Layout Changes' do
  let(:user) { create(:ldap_user) }

  before(:each) do
    sign_in(user)
  end

  scenario 'There should be no hidden dropdown menu in the main search bar' do
    visit '/'
    expect(find('#search-form-header')).not_to have_css('button.dropdown-toggle')
  end
end