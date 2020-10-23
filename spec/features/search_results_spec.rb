require 'rails_helper'
require 'webdrivers/chromedriver'
include FeatureMacros
i_need_ldap

RSpec.feature 'Search Results' do
  let(:user) { create(:ldap_user) }
  let(:image1) { create(:image) }

  before(:each) do
    sign_in(user)
  end

  context 'to display or not to display' do
    scenario 'valid images should display' do
      expect(image1).to show_in_search_results
    end

    scenario 'non_trove images should not display' do
      expect(create(:image, displays_in: nil)).not_to show_in_search_results
    end
  end

  context '.tufts-dropzone dictates who can drag to which collection' do
    scenario 'users can drag to personal colls, admin can drag to both', js: true, slow: true do
      image1
      c_coll = create(:course_collection)
      p_coll = create(:personal_collection, user: user)

      visit '/'
      find('#search-submit-header').click
      expect(page).to have_css("##{p_coll.id}.tufts-dropzone") # Can drop in personal collection
      expect(page).to have_css("##{c_coll.id}") # Can see course collection ...
      expect(page).not_to have_css("##{c_coll.id}.tufts-dropzone") # ... but can't drop in it

      user.add_role('admin')
      find('#search-submit-header').click
      expect(page).to have_css("##{c_coll.id}.tufts-dropzone") # Admin can drop in course collection
    end

  # scenario 'dragging an image into a collection adds it to the collection', js: true, slow: true do
  #   coll = create(:personal_collection, user: user)
  #
  #   visit '/'
  #   find('#search-submit-header').click
  #
  #   driver = page.driver.browser
  #   target_img = driver.find_element(id: "document_#{image1.id}")
  #
  #   # target_img = find("#document_#{image1.id}")
  #   # target_coll = find("##{coll.id}.tufts-dropzone")
  #   #
  #   # expect(coll.member_work_ids).to eq([])
  #   # selenium_webdriver = page.driver.browser
  #   # target_img = selenium_webdriver.find_element(id: "document_#{image1.}")
  #   # target_coll = selenium_webdriver.find_element(id: "#{coll.id}")
  #   # selenium_webdriver.action.click_and_hold(target_img).move_to(target_coll).release.perform
  #   # target_img.drag_to(target_coll)
  #   # sleep 2
  #   # expect(coll.member_work_ids).to eq([image1.id])
  # end
  end
end
