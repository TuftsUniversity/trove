require 'rails_helper'
include FeatureMacros
i_need_ldap

RSpec.feature 'Layout Changes' do
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

  scenario 'lots of things shouldnt display on collection show pages' do
    coll = create(:personal_collection, user: user)
    image = create(:image)
    coll.add_member_objects([image.id])
    visit "/collections/#{coll.id}"

    # Header shouldn't contain:
    # * Visibility badge
    # * Total item count
    # * Last updated
    # * Creator
    header = find('header.hyc-generic')
    expect(header).not_to have_content('Public')
    expect(header).not_to have_content('Private')
    expect(header).not_to have_content('1 Item')
    expect(header).not_to have_content('Last Updated:')
    expect(header).not_to have_content('Created by:')

    # No Collection Info box
    expect(page).not_to have_css('.hyc-metadata')

    # Search results shouldn't contain sorting options
    expect(find('.hyc-bl-sort')).not_to have_content('Sort by')
    # Per page options and default per page selection should match CatalogController config
    per_page_opts = all('#per_page > option').map(&:value)
    expect(per_page_opts).to eq(["12","24","50","100"])
    expect(find('#per_page > option[selected]').text).to eq("24")

    # no bookmark checkbox on images
    expect(find("#document_#{image.id}")).not_to have_css('.bookmark_toggle')

    # Search results list view shouldn't contain:
    # * Visibility column or links
    # * Is part of: collections info
    click_on('List')
    results = find('.hyc-bl-results')
    expect(results).not_to have_content('Visibility')
    expect(results).not_to have_css('.visibility-link')
    expect(results).not_to have_content('Is part of:')
  end
end