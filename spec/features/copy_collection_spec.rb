require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'Copy a Collection' do
  #let(:collection_type) { create(:user_collection_type) }
  let(:user) do
    User.new { |u| u.save(validate: false) }
  end

  let(:collection) { build(:collection_lw, user: user) }

  before do
    login_as user
  end

  scenario do
    visit '/dashboard/collections'
    save_and_open_page
  end
end
