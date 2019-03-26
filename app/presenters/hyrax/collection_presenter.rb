#@file
# Temporary monkey patch until Epigaea gets upgraded
require_dependency Hyrax::Engine.root.join('app', 'presenters', 'hyrax', 'collection_presenter').to_s

module Hyrax
  class CollectionPresenter
    def collection_type
      begin
        @collection_type ||= Hyrax::CollectionType.find_by_gid!(collection_type_gid)
      rescue StandardError
        @collection_type = Hyrax::CollectionType.all.first
      end
    end
  end
end
