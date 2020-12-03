require 'rails_helper'
require 'webdrivers/chromedriver'
include FeatureMacros
i_need_ldap

RSpec.feature 'Feature Image' do
  let(:user) { create(:ldap_user) }
  let(:image) { create(:image) }
  let(:image_page) { hyrax_image_path(id: image.id) }

  before(:each) do
    sign_in(user)
  end

  scenario 'non-admins cant see feature button' do
    visit image_page
    expect(page).not_to have_content('Feature')
  end

  scenario 'admins can feature and unfeature images, creating a FreaturedImage object', js: true do
    user.add_role('admin')
    expect(FeaturedWork.all.count).to eq(0)

    visit image_page
    click_on('Feature')
    sleep 1
    expect(FeaturedWork.all.count).to eq(1)
    expect(FeaturedWork.first.work_id).to eq(image.id)

    visit image_page
    click_on('Unfeature')
    sleep 1
    expect(FeaturedWork.all.count).to eq(0)
  end
end