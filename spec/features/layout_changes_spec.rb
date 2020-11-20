require 'rails_helper'
include FeatureMacros
i_need_ldap

RSpec.feature 'General Layout Changes' do
  let(:user) { create(:ldap_user) }

  before(:each) do
    sign_in(user)
  end

  scenario 'no dropdown menu in the main search bar' do
    visit '/'
    expect(find('#search-form-header')).not_to have_css('button.dropdown-toggle')
  end

  scenario 'no citations option on Images' do
    image = create(:image)
    visit "/concern/images/#{image.id}"
    expect(page).not_to have_css('.citations button')
  end

  scenario 'no Issue Type in contact form' do
    visit 'contact'
    expect(page).not_to have_content('Issue Type')
  end
end