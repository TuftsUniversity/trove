require 'rails_helper'
include FeatureMacros
i_need_ldap

RSpec.feature 'Layout Changes' do
  let(:user) { create(:ldap_user) }

  before(:each) do
    sign_in(user)
  end

  scenario 'should be no hidden dropdown menu in the main search bar' do
    visit '/'
    expect(find('#search-form-header')).not_to have_css('button.dropdown-toggle')
  end

  scenario 'should not be a citations option on Images' do
    image = create(:image)
    visit "/concern/images/#{image.id}"
    expect(page).not_to have_css('.citations button')
  end

  scenario 'should not be a bookmark checkbox option on images in collections' do
    coll = create(:personal_collection, user: user)
    image = create(:image)
    coll.add_member_objects([image.id])
    visit "/collections/#{coll.id}"
    expect(find("#document_#{image.id}")).not_to have_css('.bookmark_toggle')
  end
end