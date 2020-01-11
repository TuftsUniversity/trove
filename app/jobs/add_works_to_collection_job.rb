class AddWorksToCollectionJob < ApplicationJob
  queue_as :trove

  ##
  # Batch adds works to a collection
  def perform(work_ids, collection_id)
    Collection.find(collection_id).add_member_objects(work_ids)
  end
end