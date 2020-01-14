module SortingHelper
  ##
  # Gets the work or subcollection order for the current collection.
  # @param (:sym) type
  #   :work or :subcollection.
  def get_collection_order(type)
    if @collection.nil?
      if @presenter.nil?
        logger.error("ERROR: Couldn't find collection or presenter.")
        return []
      end
      collection = Collection.find(@presenter.id)
    else
      collection = @collection
    end

    case type
    when :work
      order = collection.work_order
    when :subcollection
      order = collection.subcollection_order
    else
      order = []
    end

    order
  end

  ##
  # Sorts subcollections for display
  # @param {arr} colls
  #   The collections from solr to sort.
  def sort_subcollections(colls)
    order = get_collection_order(:subcollection)
    return colls if order.blank?
    colls.sort_by { |e| order.index(e.id) || 1000 }
  end

  ##
  # Sorts the course collections at the top-level in the sidebar
  def sort_top_level_collections(colls, user_id = nil)
    order = user_id.nil? ? TopLevelCollectionOrder.course_collection_order : TopLevelCollectionOrder.search_by_user(user_id)
    return colls if order.empty?

    colls.sort_by { |e| order.index(e[:id]) || 1000 }
  end
end