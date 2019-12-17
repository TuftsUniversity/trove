module CollectionTypeHelpers
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
end
