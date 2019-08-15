module ApplicationHelper
  def icon(type)
    content_tag 'span', '', class: "glyphicon glyphicon-#{type}"
  end

  def is_course_collection?(collection)
    collection.collection_type.title == "Course Collection"
  end

  def is_personal_collection?(collection)
    collection.collection_type.title == "Personal Collection"
  end
end
