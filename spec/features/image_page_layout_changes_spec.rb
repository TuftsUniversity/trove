require 'rails_helper'
include FeatureMacros
include FeatureHelpers
i_need_ldap

RSpec.feature 'Image Page Layout Changes' do
  let(:user) { create(:ldap_user) }
  let(:image) { create(:image) }
  let(:image_page) { hyrax_image_path(id: image.id) }

  before(:each) do
    sign_in(user)
  end

  scenario 'no citations option on Images' do
    visit image_page
    expect(page).not_to have_content('Citations')
  end

  scenario 'no social media buttons on image pages' do
    visit image_page
    expect(page).not_to have_css('.social-media')
  end

  scenario 'swap Download image link for link to IIIF viewer, on image pages' do
    work = create(:image, user: user)
    fs = create(:file_set, user: user)
    allow(fs).to receive(:mime_type).and_return('image/png')
    attach_file_set_to_work(work, fs)

    visit hyrax_image_path(id: work.id)
    expect(page).not_to have_content('Download image')
    expect(page).not_to have_content('Download the file')
    expect(page).to have_content('open in viewer')
  end

  scenario 'associated collections on image page are displayed and separated by collection type' do
    p = create(:personal_collection, title: ['test-personal'])
    p.add_member_objects(image.id)
    c = create(:course_collection, title: ['test-course'])
    c.add_member_objects(image.id)

    visit hyrax_image_path(id: image.id)
    dts = all('.panel-body dt')
    dds = all('.panel-body dd')
    expect(dts[1]).to have_content('Course Collections')
    expect(dds[1]).to have_content('test-course')
    expect(dts[2]).to have_content('Personal Collections')
    expect(dds[2]).to have_content('test-personal')
  end
end