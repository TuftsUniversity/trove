require 'rails_helper'
include FeatureMacros
i_need_ldap

RSpec.feature 'Collection Actions' do
  let(:user) { create(:ldap_user) }

  before(:each) do
    sign_in(user)
  end

  def my_collections
    Collection.where("depositor_tesim: #{user.username}")
  end

  def course_collections
    Collection.all.select { |c| c.collection_type.title == "Course Collection" }
  end

  context 'copy collection action' do
    let(:coll) { create(:course_collection, description: ['abstract or description']) }

    scenario 'creates a new collection with copied title and metadata', slow: true do
      coll
      expect(my_collections.count).to eq(0)

      visit("/collections/#{coll.id}")
      within('.tufts-action-button') do
        find('button').click
        find('.copy-collection').click
      end

      all_cs = my_collections
      expect(all_cs.count).to eq(1)

      c = all_cs.first
      expect(c.title).to eq(coll.title)
      expect(c.description).not_to be_empty
      expect(c.description).to eq(coll.description)
    end

    scenario 'copies images and image order', slow: true do
      coll
      image1 = create(:image)
      image2 = create(:image)
      order = [image2.id, image2.id]
      coll.add_member_objects([image1.id, image2.id])
      coll.update_order(order, :work)

      visit("/collections/#{coll.id}")
      within('.tufts-action-button') do
        find('button').click
        find('.copy-collection').click
      end

      c = my_collections.first
      expect(c.member_work_ids).not_to be_empty
      expect(c.member_work_ids).to eq(coll.member_work_ids)
      expect(c.work_order).to eq(order)
    end
  end

  context 'download pdf and ppt' do
    # This functionality is already well tested in the exporters, services, and writers tests.
  end

  context 'upgrade collection action' do
    let(:coll) { create(:personal_collection, user: user, with_permission_template: true) }

    scenario 'non-admin cannot see upgrade button' do
      coll
      visit "/dashboard/collections/#{coll.id}"
      expect(page).not_to have_content('Upgrade to Course Collection')

      user.add_role('admin')
      visit "/dashboard/collections/#{coll.id}"
      expect(page).to have_content('Upgrade to Course Collection')
    end

    scenario 'copies a personal collection but makes it a course collection' do
      user.add_role('admin')
      coll

      expect(course_collections.count).to eq(0)

      visit "/dashboard/collections/#{coll.id}"
      within('.tufts-action-button') do
        find('button').click
        find('.upgrade-collection').click
      end

      cc = course_collections
      expect(cc.count).to eq(1)
      expect(cc.first.title).to eq(coll.title)
    end
  end
end