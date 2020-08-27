require 'rails_helper'
include FeatureMacros
i_need_ldap

RSpec.feature 'Collection Sidebar' do
  context 'personal collections' do
    let(:user) { create(:ldap_user) }
    let(:good_coll) { create(:personal_collection, user: user, with_permission_template: true,  with_solr_document: true) }
    let(:coll_by_other_user) { create(:personal_collection, with_solr_document: true) }
    let(:child_coll) { create(:personal_collection, user: user, parent: good_coll, with_solr_document: true) }

    before(:each) do
      sign_in(user)
      visit '/'
    end

    context 'to display or not to display' do
#      scenario 'valid collection should display' do
#        good_coll
#        sleep 5
#        title = good_coll.title.first
#        visit '/'
#        byebug
#        expect(find('#personal_collections')).to have_content(title)
#      end

      skip 'collection by a different user should not display' do
      end

      skip 'child collection should be hidden, until revealed' do
      end
    end

    context 'adding a collection via + button' do
      scenario 'collection appears in sidebar' do
        user.add_role('admin')
        visit('/')

        ['course', 'personal'].each do |type|
          title = "I am showing, #{type}"
          div = "##{type}_collections"
          within(div) { click_link('+') }

          expect(current_path).to eq('/dashboard/collections/new')
          fill_in('collection_title', with: title)
          click_button('Save')

          expect(current_path).to eq('/')
          expect(find(div)).to have_content(title)
        end
      end
    end
  end
end
