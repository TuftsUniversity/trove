class SearchBuilder < Hyrax::CatalogSearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include BlacklightRangeLimit::RangeLimitBuilder

  # Add a filter query to restrict the search to documents the current user has access to
  include Hydra::AccessControlsEnforcement
  include Hyrax::SearchFilters

  self.default_processor_chain += [:add_trove_filter, :clean_query]

  def add_trove_filter(solr_params)
    solr_params[:fq] ||= []
    solr_params[:fq] << 'displays_in_tesim:trove'
  end

  ##
  # Removes duplicate and empty fq values.
  def clean_query(solr_params)
    solr_params[:fq] = solr_params[:fq].reject(&:blank?).uniq
  end

  #def suppress_embargo_records(solr_parameters)
  #  solr_parameters[:fq] ||= []
  #  solr_parameters[:fq] << '-embargo_release_date_dtsi:[NOW TO *]'
  #end

  ##
  # @example Adding a new step to the processor chain
  #   self.default_processor_chain += [:add_custom_data_to_query]
  #
  #   def add_custom_data_to_query(solr_parameters)
  #     solr_parameters[:custom] = blacklight_params[:user_value]
  #   end
end
