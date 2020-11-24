require 'rails_helper'
include FeatureMacros
i_need_ldap

RSpec.feature 'Breadcrumb Customizations' do
  let(:user) { create(:ldap_user) }
  let(:coll) { create(:personal_collection, user: user) }
  let(:image) { create(:image) }

  scenario 'referring Collection should show in breadcrumbs on image pages' do
    sign_in(user)
    coll.add_member_objects([image.id])
    title = coll.title.first
    coll_url = hyrax.collection_path(id: coll.id)

    visit '/'
    click_on(title)
    find("#document_#{image.id} > .thumbnail > a").click

    bc = find('.breadcrumb')
    expect(bc).to have_content(title)
    expect(bc).to have_css("a[href=\"#{coll_url}\"]")
  end
end