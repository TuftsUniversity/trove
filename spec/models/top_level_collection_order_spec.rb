require 'rails_helper'

RSpec.describe TopLevelCollectionOrder, type: :model do
  let(:tlco_obj) { build(:top_level_collection_order) }
  let(:persisted_tlco_obj) { create(:top_level_collection_order) }

  it 'has a valid factory' do
    expect(tlco_obj).to be_valid
  end

  it 'rejects orders with no user_id' do
    expect(build(:invalid_top_level_collection_order)).not_to be_valid
  end

  it 'rejects orders with duplicate user_ids' do
    persisted_tlco_obj
    expect(tlco_obj).not_to be_valid
  end

  describe '#self.search_by_user' do
    it 'returns the order array with a valid user_id' do
      persisted_tlco_obj
      expect(TopLevelCollectionOrder.search_by_user('fake_id01')).to eq(['fake', 'order'])
    end

    it 'returns [] with an invalid user_id' do
      expect(TopLevelCollectionOrder.search_by_user('no_user_with_this_id')).to eq([])
    end
  end

  describe '#self.course_collection_order' do
    it 'returns the top level course collection order array, if it is instantiated' do
      create(:top_level_course_collection_order)
      expect(TopLevelCollectionOrder.course_collection_order).to eq(['fake', 'course', 'order'])
    end
  end

  describe '#self.set_for_user' do
    let(:user) { create(:user) }

    it 'does not save if user is invalid' do
      TopLevelCollectionOrder.set_for_user('no_user_here', ['this', 'wont', 'get', 'saved'])
      expect(TopLevelCollectionOrder.count).to eq(0)
    end

    it 'instantiates an order if there is not one already' do
      expect(TopLevelCollectionOrder.count).to eq(0)
      TopLevelCollectionOrder.set_for_user(user.id, ['some', 'ids'])
      expect(TopLevelCollectionOrder.count).to eq(1)
    end

    it 'saves personal collection ids that are valid', slow: true do
      coll = create(:personal_collection, user: user)

      expect(TopLevelCollectionOrder.search_by_user(user.id)).to eq([])
      TopLevelCollectionOrder.set_for_user(user.id, [coll.id])
      expect(TopLevelCollectionOrder.search_by_user(user.id)).to eq([coll.id])
    end

    it 'rejects collection ids if they dont exist', slow: true do
      TopLevelCollectionOrder.set_for_user(user.id, ['some_nonsense', 'more_nonsense'])
      expect(TopLevelCollectionOrder.search_by_user(user.id)).to eq([])
    end

    it 'rejects collection ids if they dont display in trove', slow: true do
      coll = create(:personal_collection, user: user, displays_in: nil)

      TopLevelCollectionOrder.set_for_user(user.id, [coll.id])
      expect(TopLevelCollectionOrder.search_by_user(user.id)).to eq([])
    end

    it 'rejects collection ids that are children of other collections', slow: true do
      parent = create(:personal_collection, user: user)
      child = create(:personal_collection, user: user, parent: parent)

      TopLevelCollectionOrder.set_for_user(user.id, [parent.id, child.id])
      expect(TopLevelCollectionOrder.search_by_user(user.id)).to eq([parent.id])
    end

    it 'rejects collection ids if they are owned by a different user', slow: true do
      coll = create(:personal_collection, user: create(:user))

      TopLevelCollectionOrder.set_for_user(user.id, [coll.id])
      expect(TopLevelCollectionOrder.search_by_user(user.id)).to eq([])
    end

    it 'rejects course collection ids', slow: true do
      coll = create(:course_collection, user: user)

      TopLevelCollectionOrder.set_for_user(user.id, [coll.id])
      expect(TopLevelCollectionOrder.search_by_user(user.id)).to eq([])
    end
  end

  describe '#self.set_course_collection_order' do
    it 'saves course collection ids that are valid', slow: true do
      coll = create(:course_collection)

      expect(TopLevelCollectionOrder.course_collection_order).to eq([])
      TopLevelCollectionOrder.set_course_collection_order([coll.id])
      expect(TopLevelCollectionOrder.course_collection_order).to eq([coll.id])
    end

    it 'rejects personal collection ids', slow: true do
      coll = create(:personal_collection)

      TopLevelCollectionOrder.set_course_collection_order([coll.id])
      expect(TopLevelCollectionOrder.course_collection_order).to eq([])
    end
  end
end