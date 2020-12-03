require 'rails_helper'
include FeatureMacros
i_need_ldap

RSpec.feature 'General Layout Changes' do
  let(:user) { create(:ldap_user) }

  before(:each) do
    sign_in(user)
  end

  scenario 'no dropdown menu in the main search bar' do
    visit '/'
    expect(find('#search-form-header')).not_to have_css('button.dropdown-toggle')
  end

  scenario 'no Issue Type in contact form' do
    visit hyrax.contact_path
    expect(page).not_to have_content('Issue Type')
  end

  scenario 'nothing but featured works and sidebar on homepage' do
    visit '/'
    expect(page).to have_css('#collections-sidebar')
    expect(page).not_to have_css('#homeTabs')
    expect(page).not_to have_content('Recently Uploaded')
    expect(page).not_to have_content('Explore Collections')
    expect(page).not_to have_content('Featured Researcher')
  end

  scenario 'no metadata displayed next to featured works' do
    image = create(:image)
    create(:featured_work, work_id: image.id)

    visit '/'
    fw = find('#featured_works')
    expect(fw).to have_content(image.title.first)
    expect(fw).not_to have_css('h3')
    expect(fw).not_to have_content('Depositor')
    expect(fw).not_to have_content('Keywords')
  end
end