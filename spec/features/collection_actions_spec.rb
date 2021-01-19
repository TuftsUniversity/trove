require 'rails_helper'
include FeatureMacros
i_need_ldap

RSpec.feature 'Collection Actions' do
  let(:user) { create(:ldap_user) }
  let(:coll) { create(:personal_collection, user: user, with_permission_template: true) }
  let(:image) { create(:image) }

  before(:each) do
    sign_in(user)
  end

  def collection_page(id = coll.id)
    hyrax.collection_path(id: id)
  end

  def dashboard_page(id = coll.id)
    hyrax.dashboard_collection_path(id: id)
  end

  def my_collections
    Collection.where("depositor_tesim: #{user.username}")
  end

  def course_collections
    Collection.all.select { |c| c.collection_type.title == "Course Collection" }
  end

  context 'button existence and permissions' do
    scenario 'show screen should have the right buttons and not the wrong ones' do
      visit collection_page
      buttons = find('.show-collection-buttons')
      expect(buttons).not_to have_content('Download PDF')
      expect(buttons).not_to have_content('Download Powerpoint')
      expect(buttons).to have_content('Additional Actions')
      expect(buttons).to have_content('Copy Collection')
      expect(buttons).to have_content('Manage collection')

      # Can only download collections if they have images in them
      coll.add_member_objects([image.id])
      visit collection_page
      buttons = find('.show-collection-buttons')
      expect(buttons).to have_content('Download PDF')
      expect(buttons).to have_content('Download Powerpoint')
    end

    scenario 'can copy and download other peoples collections, but cant manage them' do
      other_coll = create(:personal_collection)
      other_coll.add_member_objects([image.id])

      visit collection_page(other_coll.id)
      buttons = find('.show-collection-buttons')
      expect(buttons).not_to have_content('Manage collection')
      expect(buttons).to have_content('Additional Actions')
      expect(buttons).to have_content('Copy Collection')
      expect(buttons).to have_content('Download PDF')
      expect(buttons).to have_content('Download Powerpoint')
    end

    scenario 'edit screen should have the right buttons and not the wrong ones' do
      user.add_role('admin')

      visit dashboard_page
      buttons = all('.collection-title-row-content')[1]
      expect(buttons).not_to have_content('Add to collection')
      expect(buttons).not_to have_content('Download PDF')
      expect(buttons).not_to have_content('Download Powerpoint')
      expect(buttons).to have_content('Additional Actions')
      expect(buttons).to have_content('Copy Collection')
      expect(buttons).to have_content('Upgrade to Course Collection')
      expect(buttons).to have_content('Edit Collection Info')
      expect(buttons).to have_content('Delete collection')

      # Can only download collections if they have images in them
      coll.add_member_objects([image.id])
      visit dashboard_page
      buttons = all('.collection-title-row-content')[1]
      expect(buttons).to have_content('Download PDF')
      expect(buttons).to have_content('Download Powerpoint')

      # Can't upgrade a collection unless you're an admin
      user.remove_role('admin')
      visit dashboard_page
      buttons = all('.collection-title-row-content')[1]
      expect(buttons).not_to have_content('Upgrade to Course Collection')
    end
  end

  context 'copy collection action' do
    let(:c_coll) { create(:course_collection, description: ['abstract or description']) }

    scenario 'creates a new collection with copied title and metadata', slow: true do
      c_coll
      expect(my_collections.count).to eq(0)

      visit collection_page(c_coll.id)
      within('.tufts-action-button') do
        find('button').click
        find('.copy-collection').click
      end

      all_cs = my_collections
      expect(all_cs.count).to eq(1)

      c = all_cs.first
      expect(is_personal_collection?(c)).to be(true)
      expect(c.title).to eq(c_coll.title)
      expect(c.description).not_to be_empty
      expect(c.description).to eq(c_coll.description)
    end

    scenario 'copies images and image order', slow: true do
      c_coll
      image1 = image
      image2 = create(:image)
      order = [image2.id, image1.id]

      c_coll.add_member_objects([image1.id, image2.id])
      c_coll.update_order(order, :work)

      visit collection_page(c_coll.id)
      within('.tufts-action-button') do
        find('button').click
        find('.copy-collection').click
      end

      c = my_collections.first
      expect(c.member_work_ids).not_to be_empty
      expect(c.member_work_ids).to eq(c_coll.member_work_ids)
      expect(c.work_order).to eq(order)
    end
  end

  context 'download pdf and ppt' do
    # This functionality is already well tested in the exporters, services, and writers tests.
  end


  context 'upgrade collection action' do
    # This uses the most of the same code as copy collection, so no need to repeat testing
    # the copying of metadata, members, or member orders. It's the same code.
    scenario 'copies a personal collection but makes it a course collection' do
      user.add_role('admin')
      coll

      expect(course_collections.count).to eq(0)

      visit dashboard_page
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