##
# Builds the search results.
class MainSearchBuilder < ::SearchBuilder

  self.default_processor_chain += [:exclude_unpublished]

  # Unpublished things are showing up in search results for some reason. suppressed_bsi is not set properly, I think.
  def exclude_unpublished(solr_params)
    solr_params[:fq] ||= []
    solr_params[:fq] << '-workflow_state_name_ssim:unpublished'
  end

  ##
  # Only show images in the main search.
  def models
    [Image]
  end
end