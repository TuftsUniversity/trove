class ReindexCollectionsJob < ApplicationJob
  queue_as :trove

  ##
  # Reindexes only trove collections.
  def perform
    Collection.where(displays_in: 'trove').each(&:update_index)
  end
end
