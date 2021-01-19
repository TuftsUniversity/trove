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

  scenario 'lots of things shouldnt display on image pages', current: true do
    visit image_page

    # No big header saying IMAGE
    expect(page).not_to have_css('h1.work-type-tag')

    # No visibility tags
    expect(page).not_to have_content('Public')
    expect(page).not_to have_content('Private')

    # No citations
    expect(page).not_to have_content('Citations')

    # No social media buttons
    expect(page).not_to have_css('.social-media')

    # No Relationships section
    expect(page).not_to have_content('Relationships')
    expect(page).not_to have_content('In Administrative Set')

    # No Related Items section
    expect(page).not_to have_content('Items')
    expect(page).not_to have_css('table.related-files')
  end

  scenario 'swap Download image link for link to IIIF viewer' do
    work = create(:image, user: user)
    fs = create(:file_set, user: user)
    allow(fs).to receive(:mime_type).and_return('image/png')
    attach_file_set_to_work(work, fs)

    visit hyrax_image_path(id: work.id)
    expect(page).not_to have_content('Download image')
    expect(page).not_to have_content('Download the file')
    expect(page).to have_content('open in viewer')
  end

  scenario 'associated collections are displayed and separated by collection type' do
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