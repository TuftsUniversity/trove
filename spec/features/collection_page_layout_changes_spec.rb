require 'rails_helper'
require 'webdrivers/chromedriver'
include FeatureMacros
i_need_ldap

RSpec.feature 'Layout Changes on Collection Pages' do
  let(:user) { create(:ldap_user) }

  before(:each) do
    sign_in(user)
  end

  context 'lots of things shouldnt display on collection pages' do
    let(:coll) { create(:personal_collection, user: user, with_permission_template: true) }
    let(:image) { create(:image) }

    before(:each) do
      coll.add_member_objects([image.id])
    end

    scenario 'show page' do
      visit hyrax.collection_path(coll.id)

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
      expect(page).not_to have_content('Sort by')
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

    scenario 'edit page', js: true, noci_local: true do
      user.add_role('admin') # Need admin role for the Add Works buttons to appear
      visit hyrax.dashboard_collection_path(coll.id)

      # No big header saying COLLECTION
      expect(page).not_to have_css('.main-header')

      # "You are editing ..." notice is visible
      expect(page).to have_content('You are editing this Collection')

      # Header shouldn't contain visibility badge
      title_row = find('.collection-title-row-wrapper')
      expect(title_row).not_to have_content('Public')
      expect(title_row).not_to have_content('Private')

      # No creating new works button
      works_section = find('.works-wrapper')
      expect(works_section).not_to have_content('Deposit new work through this collection')
      expect(works_section).not_to have_content('Add existing works to this collection')

      # Search results shouldn't contain sorting options
      expect(page).not_to have_content('Sort By')
      # Per page options and default per page selection should match CatalogController config
      per_page_opts = all('#per_page > option').map(&:value)
      expect(per_page_opts).to eq(["12","24","50","100"])
      expect(page).to have_css('#per_page > option[selected]')
      expect(find('#per_page > option[selected]').text).to eq("24")

      # no bookmark checkbox on images
      expect(find("#document_#{image.id}")).not_to have_css('.bookmark_toggle')

      # Search results list view shouldn't contain:
      # * Visibility column or links
      # * Is part of: collections info
      click_on('List')
      results = find('.collection-works-table')
      expect(results).not_to have_content('Visibility')
      expect(results).not_to have_css('.visibility-link')
      expect(results).not_to have_content('Is part of:')
    end
  end

  scenario 'add-subcollection modal shows collection type and sorts collections options', js: true do
    perms = { deposit_users: [user.user_key] }

    coll1 = create(
      :personal_collection,
      user: user,
      with_permission_template: perms,
      title: ['cccc']
    )
    coll2 = create(
      :personal_collection,
      user: user,
      with_permission_template: perms,
      title: ['bbbb']
    )
    coll3 = create(
      :personal_collection,
      user: user,
      with_permission_template: perms,
      title: ['aaaa']
    )

    visit hyrax.dashboard_collection_path(coll1.id)
    click_on('Add a subcollection')

    modal_content = find("#add-subcollection-modal-#{coll1.id} .modal-body")
    expect(modal_content).to have_content('(Listing Personal Collections)')

    # Alphabetize collections in select
    select_values = modal_content.all('select > option').collect(&:text)
    expect(select_values).to eq(['Select', coll3.title.first, coll2.title.first])
  end
end
