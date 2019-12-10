require 'hyrax/name'

module HyraxHelper
  include ::BlacklightHelper
  include Hyrax::BlacklightOverride
  include Hyrax::HyraxHelperBehavior

  def sort_works(documents)
    if @collection.nil?
      if @presenter.nil?
        logger.error("ERROR: Couldn't find collection or presenter.")
        return documents
      end
      begin
        order = JSON.parse(Collection.find(@presenter.id).work_order)
      rescue
        []
      end
    else
      begin
        order = JSON.parse(@collection.work_order)
      rescue
        []
      end
    end

    if validate_matching_orders(order, documents)
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
    else
      documents
    end
  end

  def validate_matching_orders(order, documents)
    return false if order.nil?

    if order.count != documents.count
      logger.error("ERROR: CollectionOrder count does not match actual work count in collection.")
      return false
    end

    document_ids = documents.map { |d| d.id }
    if order.sort != document_ids.sort
      logger.error("ERROR: CollectionOrder ids don't match actual work ids in collection.")
      logger.error("Order: #{order}")
      logger.error("Documents: #{document_ids}")
      return false
    end

    true
  end

  ##
  # @function
  # Retrieves a list of collections, limited by collection type, that don't have parents.
  # @param {str} type
  #   The type of collection, 'personal' sets it to Personal Collections, otherwise it's always Course Collections.
  def get_top_level_collections(type = 'course')
    if(type == 'personal')
      collection_id = personal_gid
    else
      collection_id = course_gid
    end
    builder = CollectionSidebarSearchBuilder.new(controller, collection_id)
    response = controller.repository.search(builder)

    docs = []
    response.documents.each do |r|
      docs << {id: r.id, title: r['title_tesim'].first}
    end

    docs.sort_by { |r| r[:title] }
  end
end
