require 'rails_helper'

RSpec.describe AddWorksToCollectionJob, type: :job do
  let(:job) { described_class }

  before(:each) { ActiveJob::Base.queue_adapter = :test }

  describe '#perform_later' do
    it 'enqueues the job' do
      expect { job.perform_later(['trove-fake', 'trove-2'], 'collection-1') }
        .to enqueue_job(described_class)
        .with(['trove-fake', 'trove-2'], 'collection-1')
        .on_queue('trove')
    end
  end

  context 'Adding ids to a collection', slow: true do
    let(:collection) { create(:course_collection) }
    let(:image_1) { create(:image) }
    let(:image_2) { create(:image) }

    it 'adds items to the collection' do
      expect(collection.member_works.count).to eq(0)
      job.perform_now([image_1.id, image_2.id], collection.id)
      expect(collection.member_works.count).to eq(2)
    end
  end
end