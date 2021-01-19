# Auto-sets thumbnails on
module ThumbnailHelper
  def set_default_thumb_if_needed(coll, works)
    # If the collection already has a thumbnail or has no works in it, use default hyrax behavior.
    if(coll.thumbnail_id.present? || works.blank?)
      return 'use default'
    end

    coll.thumbnail_id = works.first.thumbnail_id
    coll.save!
    Hyrax::ThumbnailPathService.call(coll)

  rescue StandardError
    Hyrax::ThumbnailPathService.call(works.first)
  end
end