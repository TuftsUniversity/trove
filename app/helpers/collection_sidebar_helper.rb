module CollectionSidebarHelper
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