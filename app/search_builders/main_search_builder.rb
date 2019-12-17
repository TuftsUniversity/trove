##
# Builds the search results.
class MainSearchBuilder < ::SearchBuilder

  ##
  # Only show images in the main search.
  def models
    [Image]
  end
end