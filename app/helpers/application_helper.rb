module ApplicationHelper
  def icon(type)
    content_tag 'span', '', class: "glyphicon glyphicon-#{type}"
  end

  ##
  # @function
  # Cuts a string down to size, unless the string is already short enough.
  # @param {hash} item
  #   Blacklight config passes an entire item hash to the function. Item[:value] should be the text.
  # @param {int} max_length
  #   The absolute max length a string can be. The function truncates to 15 characters less than this,
  #   to avoid deleting a single word, which would be a useless amount of truncation.
  def limit_text_length(item, max_length = 170)
    return '' if item[:value].empty? || item[:value].first.empty?

    descrip = item[:value].first
    if (descrip.length <= max_length)
      return descrip
    end

    descrip.truncate(max_length - 15, separator: ' ')
  end

  # Tells the gallery view if it's on the search page or not.
  def on_search_page?
    params['controller'] == 'catalog' && params['action'] == 'index'
  end

  # Tells the gallery view if it's in the collection dashboard or not.
  def on_edit_page?
    params['controller'] == 'hyrax/dashboard/collections'
  end
end
