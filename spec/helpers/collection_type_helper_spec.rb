require 'rails_helper'

# CollectionTypes are generated in rails_helper.
RSpec.describe CollectionTypeHelper, type: :helper do
  let(:course_collection) { build(:course_collection) }
  let(:personal_collection) { build(:personal_collection) }

  describe '#personal_gid' do
    it 'returns a gid string successfully' do
      expect(helper.personal_gid).to match(/^gid:\/\/trove\/hyrax-collectiontype\/\d+$/)
    end
  end

  describe '#course_gid' do
    it 'returns a gid string successfully' do
      expect(helper.course_gid).to match(/^gid:\/\/trove\/hyrax-collectiontype\/\d+$/)
    end
  end

  describe '#personal_id' do
    it 'returns an id successfully' do
      expect(helper.personal_id).to be_an(Numeric)
    end
  end

  describe '#course_id' do
    it 'returns an id successfully' do
      expect(helper.course_id).to be_an(Numeric)
    end
  end

  describe '#is_course_collection?' do
    it 'returns true on course collections' do
      expect(helper.is_course_collection?(course_collection)).to eq(true)
    end

    it 'returns false on personal collections' do
      expect(helper.is_course_collection?(personal_collection)).to eq(false)
    end
  end

  describe '#is_personal_collection?' do
    it 'returns true on personal collections' do
      expect(helper.is_personal_collection?(personal_collection)).to eq(true)
    end

    it 'returns false on course collections' do
      expect(helper.is_personal_collection?(course_collection)).to eq(false)
    end
  end
end