class SearchBuilder < Hyrax::CatalogSearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include BlacklightRangeLimit::RangeLimitBuilder

  # Add a filter query to restrict the search to documents the current user has access to
  include Hydra::AccessControlsEnforcement
  include Hyrax::SearchFilters

  self.default_processor_chain += [:add_trove_filter, :suppress_embargo_records]

  def add_trove_filter(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << 'displays_in_tesim:trove'
  end

  # Override default behavior so admin users can see unpublished works in the search results
  def suppress_embargo_records(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << '-suppressed_bsi:true'
    solr_parameters[:fq] << '-embargo_release_date_dtsi:[NOW TO *]'
  end

  ##
  # @example Adding a new step to the processor chain
  #   self.default_processor_chain += [:add_custom_data_to_query]
  #
  #   def add_custom_data_to_query(solr_parameters)
  #     solr_parameters[:custom] = blacklight_params[:user_value]
  #   end
end
