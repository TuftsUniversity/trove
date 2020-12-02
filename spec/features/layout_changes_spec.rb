require 'rails_helper'
include FeatureMacros
include FeatureHelpers
i_need_ldap

RSpec.feature 'General Layout Changes' do
  let(:user) { create(:ldap_user) }
  let(:image) { create(:image) }
  let(:image_page) { hyrax_image_path(id: image.id) }

  before(:each) do
    sign_in(user)
  end

  scenario 'no dropdown menu in the main search bar' do
    visit '/'
    expect(find('#search-form-header')).not_to have_css('button.dropdown-toggle')
  end

  scenario 'no citations option on Images' do
    visit image_page
    expect(page).not_to have_css('.citations button')
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

  scenario 'no Issue Type in contact form' do
    visit hyrax.contact_path
    expect(page).not_to have_content('Issue Type')
  end
end