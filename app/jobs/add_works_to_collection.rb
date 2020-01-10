class AddWorksToCollectionJob < ApplicationJob
  ##
  # Batch adds works to a collection
  def perform(work_ids, collection)
    collection.add_member_objects(work_ids)
  end
end