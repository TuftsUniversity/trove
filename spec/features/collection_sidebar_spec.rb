require 'rails_helper'
require 'webdrivers/chromedriver'
include FeatureMacros
i_need_ldap

RSpec.feature 'Collection Sidebar' do
  let(:user) { create(:ldap_user) }
  let(:pers_coll) { create(:personal_collection, user: user) }

  before(:each) do
    sign_in(user)
  end

  context 'to display or not to display' do
    scenario 'valid collections should display', slow: true do
      pers_coll
      crs_coll = create(:course_collection)
      expect(pers_coll).to show_in_personal_sidebar
      expect(crs_coll).to show_in_course_sidebar
    end

    scenario 'PrivateCollections by a different user should not display', slow: true do
      coll = create(:personal_collection)
      expect(coll).not_to show_in_personal_sidebar
    end

    scenario 'restricted CourseCollections should not display', slow: true do
      coll = create(
        :course_collection,
        visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
      )
      expect(coll).not_to show_in_course_sidebar
    end

    scenario 'non-trove collections should not display', slow: true do
      coll = create(:personal_collection, user: user, displays_in: nil)
      expect(coll).not_to show_in_personal_sidebar
    end

    scenario 'child collection should be hidden, until revealed', js: true, slow: true do
      pers_coll
      child_coll = create(:personal_collection, user: user, parent: pers_coll)
      visit '/'
      expect(page).to have_selector("##{child_coll.id}", visible: false)
      find("li[data-id=\"#{pers_coll.id}\"] > button").click
      expect(page).to have_selector("##{child_coll.id}")
    end

    scenario 'non-admin should only see + and rearrange buttons on personal collections' do
      visit '/'
      expect(find('#personal_collections')).to have_content('+')
      expect(page).to have_css('button.reorder-personal')
      expect(find('#course_collections')).not_to have_content('+')
      expect(page).not_to have_css('button.reorder-course')
    end
  end

  context 'adding a collection via + button' do
    scenario 'collection appears in sidebar', slow: true, js: true, noci_local: true do
      user.add_role('admin')
      visit('/')

      ['course', 'personal'].each do |type|
        title = "I am showing, #{type}"
        div = "##{type}_collections"
        within(div) { click_link('+') }

        expect(current_path).to eq('/dashboard/collections/new')
        fill_in('collection_title', with: title)
        click_button('Save')

        expect(current_path).to eq('/')
        expect(find(div)).to have_content(title)
      end
    end
  end

  context 'rearranging TopLevelCollections' do
    ##
    # Returns Personal Collection sidebar NodeList and ids.
    def get_sidebar_els_and_ids
      list = all('.top-level-personal-collections > li')
      return list, list.map { |node| node['data-id'] }
    end

    ##
    # Swaps the Personal Collection sidebar collections around a bit.
    def rearrange_collections(arr_btn, collections)
      arr_btn.click
      collections[0].drag_to(collections[2])
      arr_btn.click
      sleep 1
    end

    scenario 'Clicking the rearrange button enables/disables rearranging', noci_local:true, js: true, slow: true do
      pers_coll
      visit('/')
      arr_btn = find('button.reorder-personal')

      expect(page).not_to have_css('.ui-sortable-handle')
      arr_btn.click
      expect(page).to have_css('.ui-sortable-handle')
      arr_btn.click
      expect(page).not_to have_css('.ui-sortable-handle')
    end

    ##
    # This tests a few things, because I don't want to fully instantiate three collections
    #    over and over. It tests:
    # * Rearranging the sidebar generates a TopLevelCollectionOrder if it doesn't exist.
    # * Rearranging the sidebar updates the TopLevelCollectionOrder if it does exist.
    # * The TopLevelCollectionOrder matches the order of the ids in the HTML.
    scenario 'Rearranging saves the order as a TopLevelCollectionOrder', noci_local:true, js: true, slow: true do
      pers_coll
      create(:personal_collection, user: user)
      create(:personal_collection, user: user)
      visit('/')
      collections_to_drag, _ = get_sidebar_els_and_ids
      arr_btn = find('button.reorder-personal')

      expect(TopLevelCollectionOrder.count).to eq(0)

      # Rearranging the sidebar _generates_ a TopLevelCollectionOrder if it doesn't exist.
      rearrange_collections(arr_btn, collections_to_drag)
      expect(TopLevelCollectionOrder.count).to eq(1)

      # The TopLevelCollectionOrder matches the order of the ids in the HTML.
      collections_to_drag, ids = get_sidebar_els_and_ids
      expect(TopLevelCollectionOrder.search_by_user(user.id)).to eq(ids)

      # Rearranging the sidebar _updates_ the TopLevelCollectionOrder if it does exist.
      rearrange_collections(arr_btn, collections_to_drag)
      expect(TopLevelCollectionOrder.count).to eq(1)

      # The TopLevelCollectionOrder matches the order of the ids in the HTML.
      _, ids = get_sidebar_els_and_ids
      expect(TopLevelCollectionOrder.search_by_user(user.id)).to eq(ids)
    end
  end
end
