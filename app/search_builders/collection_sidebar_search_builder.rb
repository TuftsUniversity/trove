##
# Builds the nested collection list for the Collection sidebar on the homepage and search results.
class CollectionSidebarSearchBuilder < Hyrax::CollectionSearchBuilder

  self.default_processor_chain += [:no_facets_or_highlight, :limit_by_collection_id, :only_top_level, :get_all_items]

  ##
  # Sets the collection_id for the collection type needed. Removes a bunch of unnecessary querying.
  # @param {controller} scope
  #   The controller to use with the search builder.
  # @param {str} collection_id
  #   The collection gid of the type that we're looking for.
  def initialize(scope, collection_id)
    @collection_id = collection_id

    # In an effort to make solr queries slightly less awful to debug, removing all faceting/range limit stuff from
    # this search builder, because we don't use facets or ranges in the collections sidebar.
    self.default_processor_chain.delete(:add_facet_fq_to_solr)
    self.default_processor_chain.delete(:add_facetting_to_solr)
    self.default_processor_chain.delete(:add_facet_paging_to_solr)
    self.default_processor_chain.delete(:filter_collection_facet_for_access)
    self.default_processor_chain.delete(:add_range_limit_params)

    super(scope)
  end

  ##
  # Overriding this, because we only need titles and ids.
  def add_solr_fields_to_query(solr_params)
    solr_params['qf'] = 'title_tesim'
    solr_params['fl'] = 'id, title_tesim'
  end

  ##
  # Removes highlighting and faceting from query.
  def no_facets_or_highlight(solr_params)
    solr_params['facet'] = false
    solr_params.delete('facet.fields')
    solr_params.delete('facet.query')
    solr_params.delete('facet.pivot')
    solr_params.delete('hl.fl')
  end

  ##
  # Returns only a single collection type, defined in initialize.
  def limit_by_collection_id(solr_params)
    solr_params[:fq] ||= []
    solr_params[:fq] << "collection_type_gid_ssim:\"#{@collection_id}\""
  end

  ##
  # Returns only top level collections (no parents)
  def only_top_level(solr_params)
    solr_params[:fq] ||= []
    solr_params[:fq] << "!(member_of_collection_ids_ssim:*)"
  end

  ##
  # Overrides the default per page, to retrieve everything.
  def get_all_items(solr_params)
    solr_params['rows'] = 100000
  end
end