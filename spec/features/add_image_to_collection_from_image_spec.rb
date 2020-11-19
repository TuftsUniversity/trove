require 'rails_helper'
require 'webdrivers/chromedriver'
include FeatureMacros
i_need_ldap

RSpec.feature 'Add image to collection from image page' do
  context 'adding images from image show page' do
    let(:user) { create(:ldap_user) }
    # For some reason, factories aren't loading with deposit perms for non-admins.
    # Non-admins on the actual site work just fine, though
    let(:my_coll) { create(
      :personal_collection,
      user: user,
      title: ['my collection'],
      with_permission_template: { deposit_users: [user.user_key] }) }
    let(:your_coll) { create(:personal_collection, title: ['other persons collection']) }
    let(:c_coll) { create(:course_collection, title: ['course collection']) }
    let(:image) { create(:image) }

    before(:each) do
      sign_in(user)
    end

    def search_in_and_return_modal
      visit("/concern/images/#{image.id}")
      click_on('Add to collection')
      fill_in('search', with: 'coll')
      find('.collection-list-modal')
    end

    scenario 'non-admins can add images only to their own collections', js: true do
      my_coll
      your_coll
      c_coll

      modal = search_in_and_return_modal
      expect(modal).to have_content("my collection (Personal Collection)")
      expect(modal).not_to have_content('other persons collection')
      expect(modal).not_to have_content('course collection')

      expect(my_coll.member_work_ids).to be_empty
      modal.choose("id_#{my_coll.id}")
      click_on('Save changes')
      expect(my_coll.member_work_ids).to eq([image.id])
    end

    scenario 'admins can add images to all collections', js: true do
      user.add_role('admin')

      my_coll
      your_coll
      c_coll

      modal = search_in_and_return_modal
      expect(modal).to have_content("my collection (Personal Collection - #{user.username})")
      expect(modal).to have_content('other persons collection (Personal Collection -')
      expect(modal).to have_content('course collection (Course Collection -')

      # modal auto-filters after initial search
      fill_in('search', with: 'course')
      expect(modal).not_to have_content('my collection')
      expect(modal).not_to have_content('other persons collection')
      expect(modal).to have_content('course collection')

      expect(my_coll.member_work_ids).to be_empty
      modal.choose("id_#{c_coll.id}")
      click_on('Save changes')
      expect(c_coll.member_work_ids).to eq([image.id])
    end
  end
end