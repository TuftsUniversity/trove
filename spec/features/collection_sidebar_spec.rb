require 'rails_helper'
require 'webdrivers/chromedriver'
include FeatureMacros
i_need_ldap

RSpec.feature 'Collection Sidebar' do
  let(:user) { create(:ldap_user) }
  let(:pers_coll) { create(:personal_collection, user: user) }

  before(:each) do
    sign_in(user)
    visit '/'
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
  end

  context 'adding a collection via + button' do
    scenario 'non-admin should only see + button on personal collections', slow: true do
      expect(find('#personal_collections')).to have_content('+')
      expect(find('#course_collections')).not_to have_content('+')
    end

    scenario 'collection appears in sidebar', slow: true do
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
end
