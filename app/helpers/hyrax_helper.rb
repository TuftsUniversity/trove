require 'hyrax/name'

module HyraxHelper
  include ::BlacklightHelper
  include Hyrax::BlacklightOverride
  include Hyrax::HyraxHelperBehavior
  include CollectionTypeHelpers

  def sort_works(documents)
    if @collection.nil?
      if @presenter.nil?
        logger.error("ERROR: Couldn't find collection or presenter.")
        return documents
      end

      collection = Collection.find(@presenter.id)
    else
      collection = @collection
    end

    return documents if collection.work_order.nil?

    order = JSON.parse(collection.work_order)
    ordered_docs = []
    order.each do |id|
      documents.each do |doc|
        if doc.id == id
          ordered_docs << doc
          break
        end
      end
    end

    ordered_docs
  end
  #
  # def validate_matching_orders(order, documents)
  #   return false if order.nil?
  #
  #   if order.count != documents.count
  #     logger.error("ERROR: CollectionOrder count does not match actual work count in collection.")
  #     return false
  #   end
  #
  #   document_ids = documents.map { |d| d.id }
  #   if order.sort != document_ids.sort
  #     logger.error("ERROR: CollectionOrder ids don't match actual work ids in collection.")
  #     logger.error("Order: #{order}")
  #     logger.error("Documents: #{document_ids}")
  #     return false
  #   end
  #
  #   true
  # end

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
