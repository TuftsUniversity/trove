require_dependency Hyrax::Engine.root.join('app', 'controllers', 'hyrax', 'dashboard', 'collections_controller').to_s

module Hyrax
  module Dashboard
    ## Shows a list of all collections to the admins
    class CollectionsController < Hyrax::My::CollectionsController
      include TuftsCollectionControllerBehavior
      with_themed_layout '1_column'

      ##
      # @function
      # Overwrites collection create method to add various customizations for trove.
      def create
        # Manual load and authorize necessary because Cancan will pass in all
        # form attributes. When `permissions_attributes` are present the
        # collection is saved without a value for `has_model.`
        @collection = ::Collection.new
        authorize! :create, @collection
        # Coming from the UI, a collection type gid should always be present.  Coming from the API, if a collection type gid is not specified,
        # use the default collection type (provides backward compatibility with versions < Hyrax 2.1.0)
        @collection.collection_type_gid = params[:collection_type_gid].presence || default_collection_type.gid
        @collection.attributes = collection_params.except(:members, :parent_id, :collection_type_gid)
        @collection.assign_attributes({'displays_in' => ['trove']}) # Added for Trove
        @collection.apply_depositor_metadata(current_user.user_key)
        add_members_to_collection unless batch.empty?
        @collection.visibility = @collection.collection_type_gid == helpers.course_gid ?
          Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC :
          Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE # Changed for Trove
        if @collection.save
          after_create
        else
          after_create_error
        end
      end

      ##
      # @function
      # Overwrites collection after_create callback to redirect to root, instead of dashboard.
      def after_create
        form
        set_default_permissions

        # if we are creating the new collection as a subcollection (via the nested collections controller),
        # we pass the parent_id through a hidden field in the form and link the two after the create.
        link_parent_collection(params[:parent_id]) unless params[:parent_id].nil?

        respond_to do |format|
          ActiveFedora::SolrService.instance.conn.commit
          format.html { redirect_to root_path, notice: t('hyrax.dashboard.my.action.collection_create_success') } #Changed for trove
          format.json { render json: @collection, status: :created, location: dashboard_collection_path(@collection) }
        end
      end

      ##
      # Add permissions!
      def upgrade
        unless(is_personal_collection?(@collection))
          redirect_to root_path, notice: t('trove_collections.additional_actions.notices.not_personal_collection')
        end

        new_collection = create_copy
        new_collection.collection_type_gid = course_gid
        new_collection.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
        new_collection.save
        ActiveFedora::SolrService.instance.conn.commit

        Tufts::Curation::CollectionOrder.new(collection_id: new_collection.id).save
        new_collection.update_work_order(@collection.work_order)

        redirect_to root_path, notice: t('trove_collections.additional_actions.notices.upgrade_success')
      end

      ##
      # Add permissions!
      def downgrade
        if(is_course_collection?(@collection))
          redirect_to root_path, notice: t('trove_collections.additional_actions.notices.not_course_collection')
        end

        new_collection = create_copy
        new_collection.collection_type_gid = personal_gid
        new_collection.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
        new_collection.save
        ActiveFedora::SolrService.instance.conn.commit

        Tufts::Curation::CollectionOrder.new(collection_id: new_collection.id).save
        new_collection.update_work_order(@collection.work_order)

        @collection.destroy!

        # redirect_to root_path, notice: t('trove_collections.additional_actions.notices.downgrade_success')
      end

      ##
      # @function
      def update_work_order
        @collection.update_work_order(JSON.parse(params[:order]))
      end

    end
  end
end
