require_dependency Hyrax::Engine.root.join('app', 'controllers', 'hyrax', 'dashboard', 'collection_members_controller').to_s
require 'sipity/entity' # Required for add_item_to_collection to work

# Patching to include updating the work order after items are added to a collection
module Hyrax
  module Dashboard
    class CollectionMembersController < Hyrax::My::CollectionsController

      # Overwrite to add the new images to the collection's work order
      def after_update
        collection.update_order(collection.work_order | batch_ids, :work)

        if(not_from_drag_n_drop)
          respond_to do |format|
            format.html { redirect_to success_return_path, notice: t('hyrax.dashboard.my.action.collection_update_success') }
            format.json { render json: @collection, status: :updated, location: dashboard_collection_path(@collection) }
          end
        end
      end

      private

        # Checks the params to see if the request is from drag and drop in search results
        def not_from_drag_n_drop
          params[:origin].blank? || params[:origin] != "dragndrop"
        end

        # Overwrite to send errors to home page instead of dashboard
        def err_return_path
          root_path
        end
    end
  end
end
