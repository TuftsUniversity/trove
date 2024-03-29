require 'rails_helper'
require 'webdrivers/chromedriver'
include FeatureMacros
i_need_ldap

RSpec.feature 'Reordering works and subcollections' do
  let(:user) { create(:ldap_user) }
  let(:coll) { create(:personal_collection, user: user, with_permission_template: true) }
  let(:dashboard_page) { hyrax.dashboard_collection_path(id: coll.id) }

  before(:each) do
    sign_in(user)
  end

  ##
  # Returns Image NodeList and ids.
  def get_image_els_and_ids
    list = all('#documents > .document')
    return list, list.map { |node| node[:id].sub('document_', '') }
  end

  ##
  # Returns Subcollection NodeList and ids.
  def get_subc_els_and_ids
    list = all('.collections-list > .ui-sortable-handle')
    return list, list.map { |node| node['data-id'] }
  end

  scenario 'rearranged work orders are persisted', slow: true, noci: true, js: true, noci_local: true do
    user.add_role('admin')

    coll
    image1 = create(:image)
    image2 = create(:image)
    image3 = create(:image)
    coll.add_member_objects([image1.id, image2.id, image3.id])

    expect(coll.work_order).to eq([])

    visit dashboard_page
    images, _ = get_image_els_and_ids
    images[0].drag_to(images[1])
    images[1].drag_to(images[2]) # Shuffle them around a bit
    images[2].drag_to(images[0])
    sleep 1

    new_order = Collection.find(coll.id).work_order
    expect(new_order).not_to eq([])

    visit dashboard_page
    _, ids = get_image_els_and_ids
    expect(ids).to eq(new_order)
  end

  scenario 'rearranged subcollection orders are persisted', noci_local: true, slow: true, js: true do
    coll
    create(:personal_collection, user: user, parent: coll)
    create(:personal_collection, user: user, parent: coll)
    create(:personal_collection, user: user, parent: coll)

    expect(coll.subcollection_order).to eq([])

    visit dashboard_page
    colls, _ = get_subc_els_and_ids
    colls[0].drag_to(colls[2])
    colls[1].drag_to(colls[0]) #Shuffle shuffle
    colls[2].drag_to(colls[0])
    sleep 1

    new_order = Collection.find(coll.id).subcollection_order
    expect(new_order).not_to eq([])

    visit dashboard_page
    _, ids = get_subc_els_and_ids
    expect(ids).to eq(new_order)
  end
end
