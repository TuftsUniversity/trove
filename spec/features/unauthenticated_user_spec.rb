require 'rails_helper'

RSpec.feature 'unauthenticated users' do
  context 'are redirected to the login page' do
    let(:login_page) { '/users/sign_in' }
    let(:work) { create(:image) }

    scenario 'when attempting to access /' do
      visit("/")
      expect(current_path).to eq login_page
    end

    scenario 'when attempting to access a work' do
      visit("/concern/images/#{work.id}")
      expect(current_path).to eq login_page
    end

    scenario 'when attempting to access the admin dashboard' do
      visit("/dashboard")
      expect(current_path).to eq login_page
    end
  end
end
