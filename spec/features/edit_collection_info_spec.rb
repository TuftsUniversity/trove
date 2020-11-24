require 'rails_helper'
include FeatureMacros
i_need_ldap

RSpec.feature 'Edit Collection Info Customizations' do
  let(:user) { create(:ldap_user) }
  let(:coll) { create(:personal_collection, user: user) }

  before(:each) do
    sign_in(user)
    visit hyrax.edit_dashboard_collection_path(id: coll.id)
  end

  scenario 'discovery tab does not contain registered visibility option - "Tufts University" sets to open visibility' do
    click_link('Discovery')
    expect(page).not_to have_css('#visibility_registered')

    open_radio = first('#discovery label')
    expect(open_radio).to have_css('#visibility_open')
    expect(open_radio).to have_content('Tufts University')
  end

  scenario 'there is no sharing tab and no additional fields option' do
    expect(find('.nav-tabs')).not_to have_content("Sharing")

    description_tab = find('#description')
    expect(description_tab).not_to have_content("Additional fields")
    expect(description_tab).not_to have_css('.btn.additional-fields')
    expect(description_tab).not_to have_css('#extended-terms')
  end
end