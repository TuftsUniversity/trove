module ApplicationHelper
  def icon(type)
    content_tag 'span', '', class: "glyphicon glyphicon-#{type}"
  end

  ##
  # @function
  # Gets the Personal Collection gid from the db.
  def personal_gid
    @personal_gid ||= Hyrax::CollectionType.where(title: "Personal Collection").first.gid
  end

  ##
  # @function
  # Gets the Course Collection gid from the db.
  def course_gid
    @course_gid ||= Hyrax::CollectionType.where(title: "Course Collection").first.gid
  end

  def is_course_collection?(collection)
    collection.collection_type.title == "Course Collection"
  end

  def is_personal_collection?(collection)
    collection.collection_type.title == "Personal Collection"
  end

  ##
  # @function
  # Cuts a string down to size, unless the string is already short enough.
  # @param {hash} item
  #   Blacklight config passes an entire item hash to the function. Item[:value] should be the text.
  # @param {int} max_length
  #   The absolute max length a string can be. The function truncates to 20 characters less than this,
  #   to avoid deleting a single word, which would be a useless amount of truncation.
  def limit_text_length(item, max_length = 170)
    return '' if item[:value].empty? || item[:value].first.empty?

    descrip = item[:value].first
    if (descrip.length <= max_length)
      return descrip
    end

    descrip.truncate(max_length - 15, separator: ' ')
  end
end
