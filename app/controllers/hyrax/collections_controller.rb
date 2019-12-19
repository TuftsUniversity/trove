require_dependency Hyrax::Engine.root.join('app', 'controllers', 'hyrax', 'collections_controller').to_s


module Hyrax
  class CollectionsController < ApplicationController
    ##
    # @function
    # Copies collections, along with their child/parent collections, works, and work order.
    def copy
      new_collection = create_copy
      new_collection.collection_type_gid = personal_gid
      new_collection.save
      ActiveFedora::SolrService.instance.conn.commit

      Tufts::Curation::CollectionOrder.new(collection_id: new_collection.id).save
      new_collection.update_work_order(@collection.work_order)

      # I don't think we want to do this, as it would mix personal and course collections in the hierarchy.
      # copy_children(new_collection)
      # copy_parents(new_collection)

      ActiveFedora::SolrService.instance.conn.commit
      redirect_to root_path, notice: t('hyrax.dashboard.my.action.collection_create_success')
    end

    private
      ##
      # @function
      # Creates a copy of a collection, with all its attributes.
      def create_copy
        new_collection = ::Collection.new(@collection.attributes.except('id'))
        new_collection.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
        new_collection
      end
  end
end
