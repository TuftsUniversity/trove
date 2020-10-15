require 'rails_helper'
include FeatureMacros
i_need_ldap

RSpec.feature 'Collection Sidebar' do
  context 'personal collections' do
    let(:user) { create(:ldap_user) }
    let(:good_coll) { create(:personal_collection, user: user) }
    let(:coll_by_other_user) { create(:personal_collection) }
    let(:child_coll) { create(:personal_collection, user: user, parent: good_coll) }

    before(:each) do
      sign_in(user)
      visit '/'
    end

    context 'to display or not to display' do
      scenario 'valid collection should display' do
        good_coll
        title = good_coll.title.first
        visit '/'
        expect(find('#personal_collections')).to have_content(title)
      end

      scenario 'collection by a different user should not display' do
        coll_by_other_user
        title = coll_by_other_user.title.first
        visit '/'
        expect(find('#personal_collections')).not_to have_content(title)
      end

      skip 'child collection should be hidden, until revealed' do
      end
    end

    # context 'adding a collection via + button' do
    #   scenario 'non-admin should only see + button on personal collections' do
    #     expect(find('#personal_collections')).to have_content('+')
    #     expect(find('#course_collections')).not_to have_content('+')
    #   end
    #
    #   scenario 'collection appears in sidebar' do
    #     user.add_role('admin')
    #     visit('/')
    #
    #     ['course', 'personal'].each do |type|
    #       title = "I am showing, #{type}"
    #       div = "##{type}_collections"
    #       within(div) { click_link('+') }
    #
    #       expect(current_path).to eq('/dashboard/collections/new')
    #       fill_in('collection_title', with: title)
    #       click_button('Save')
    #
    #       expect(current_path).to eq('/')
    #       expect(find(div)).to have_content(title)
    #     end
    #   end
    # end
  end
end
