require 'rails_helper'
include FeatureMacros
i_need_ldap

RSpec.feature 'Search Results' do
  let(:user) { create(:ldap_user) }
  let(:image1) { create(:image) }

  before(:each) do
    sign_in(user)
  end

  context 'to display or not to display' do
    scenario 'valid images should display' do
      expect(image1).to show_in_search_results
    end

    scenario 'non_trove images should not display' do
      expect(create(:image, displays_in: nil)).not_to show_in_search_results
    end
  end

  context '.tufts-dropzone dictates who can drag to which collection' do
    scenario 'users can drag to personal colls, admin can drag to both', slow: true do
      image1
      p_coll = create(:personal_collection, user: user)

      visit '/'
      find('#search-submit-header').click
      expect(page).to have_css("##{p_coll.id}.tufts-dropzone") # Can drop in personal collection
      expect(page).to have_css("##{c_coll.id}") # Can see course collection ...
      expect(page).not_to have_css("##{c_coll.id}.tufts-dropzone") # ... but can't drop in it

      user.add_role('admin')
      find('#search-submit-header').click
      expect(page).to have_css("##{c_coll.id}.tufts-dropzone") # Admin can drop in course collection
    end
  end

  scenario 'dragging an image into a collection adds it to the collection' do
    # There doesn't appear to be any meaningful way to test this via javascript.
    # MDN states in the DragEvent constructor:
    ##   Although this interface has a constructor, it is not possible to create a useful
    ##   DataTransfer object from script, since DataTransfer objects have a processing and
    ##   security model that is coordinated by the browser during drag-and-drops.
    # We use DataTransfer objects, and this combined with fact that Selenium doesn't support
    # drag events, we have to just go straight to the route for now.

    # I considered doing a test against the route that the AJAX call hits, but that route
    # is native to Hyrax, and thus is tested by Hyrax already.
  end
end
