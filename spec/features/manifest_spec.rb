require 'rails_helper'
include FeatureMacros
i_need_ldap

RSpec.feature 'IIIF Manifest Customizations' do
  scenario 'manifest should have copyright notice' do
    sign_in(create(:ldap_user))
    image = create(:image)

    visit manifest_hyrax_image_path(image.id)
    expect(page).to have_content(I18n.t('copyright_acknowledgement.value'))
  end
end
