require 'hyrax/name'

module HyraxHelper
  include ::BlacklightHelper
  include Hyrax::BlacklightOverride
  include Hyrax::HyraxHelperBehavior
  include CollectionTypeHelpers


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
      return []
    end

    order
  end

  ##
  # Sorts works for display inside collections.
  # @param (arr) documents
  #   The works inside the collection.
  def sort_works(documents)
    order = get_collection_order(:work)
    return documents if order.empty?


    new_order = order.select do |id|
      documents.any? { |doc| doc.id == id }
    end

    documents
  end

  ##
  # @function
  # Retrieves a list of collections, limited by collection type, that don't have parents.
  # @param {str} type
  #   The type of collection, 'personal' sets it to Personal Collections, otherwise it's always Course Collections.
  def get_top_level_collections(type = 'course')
    get_collections(type)
  end

  ##
  # @function
  # Retrieves a list of collections, limited by collection type and parent collection.
  # @param {str} parent_id
  #   The parent collection's ID, or nil if you want top-level collections.
  # @param {str} type
  #   The type of collection, 'personal' sets it to Personal Collections, otherwise it's always Course Collections.
  def get_collections(type = 'course', parent_id = nil)
    builder = CollectionSidebarSearchBuilder.new(controller, type, parent_id)
    response = controller.repository.search(builder)

    docs = []
    response.documents.each do |r|
      docs << {id: r.id, title: r['title_tesim'].first}
    end

    docs.sort_by { |r| r[:title] }
  end
end
