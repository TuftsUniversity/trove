require_dependency Hyrax::Engine.root.join('app', 'controllers', 'hyrax', 'dashboard', 'collections_controller').to_s

module Hyrax
  module Dashboard
    ## Shows a list of all collections to the admins
    class CollectionsController < Hyrax::My::CollectionsController
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
        create_collection_order

        respond_to do |format|
          ActiveFedora::SolrService.instance.conn.commit
          format.html { redirect_to root_path, notice: t('hyrax.dashboard.my.action.collection_create_success') } #Changed for trove
          format.json { render json: @collection, status: :created, location: dashboard_collection_path(@collection) }
        end
      end
      
      def dl_pdf
        @curated_collection = ::Collection.find(params[:id])
        respond_to do |format|
          format.pdf do
            exporter = PdfCollectionExporter.new(@curated_collection)
            send_file(exporter.export, filename: exporter.pdf_file_name, type: "application/pdf")
          end
        end
      end

      def dl_powerpoint
        @curated_collection = ::Collection.find(params[:id])
        respond_to do |format|
          format.pptx do
            exporter = PowerPointCollectionExporter.new(@curated_collection)
            send_file(exporter.export,
                  filename: exporter.pptx_file_name,
                  type: "application/vnd.openxmlformats-officedocument.presentationml.presentation")
          end
        end
      end

      ##
      # @function
      # Copies collections, along with their child/parent collections, works, and work order.
      def copy
        new_collection = create_copy

        ActiveFedora::SolrService.instance.conn.commit

        copy_children(new_collection)
        copy_parents(new_collection)

        ActiveFedora::SolrService.instance.conn.commit
        redirect_to root_path, notice: t('hyrax.dashboard.my.action.collection_create_success')
      end

      ##
      # Add permissions!
      # Change visibility to public!
      def upgrade
        if(@collection.collection_type.title != "Personal Collection")
          redirect_to root_path, notice: t('trove_collections.notices.not_personal_collection')
        end

        course_collection_type = Hyrax::CollectionType.where(title: "Course Collection").first
        @collection.collection_type = course_collection_type
        @collection.save

        redirect_to :back, notice: t('trove_collections.additional_actions.notices.upgrade_success')
      end

      ##
      # Add permissions!
      # Change visibility to public!
      def downgrade
        if(@collection.collection_type.title != "Course Collection")
          redirect_to root_path, notice: t('trove_collections.notices.not_course_collection')
        end

        personal_collection_type = Hyrax::CollectionType.where(title: "Personal Collection").first
        @collection.collection_type = personal_collection_type
        @collection.save

        redirect_to :back, notice: t('trove_collections.additional_actions.notices.downgrade_success')
      end

      ##
      # @function
      def update_work_order
        @collection.update_work_order(JSON.parse(params[:order]))
      end


        private

        ##
        # @function
        # Creates a collection order object for this collection.
        def create_collection_order
          Tufts::Curation::CollectionOrder.new(collection_id: @collection.id).save
        end

        ##
        # @function
        # Creates a copy of a collection, with all its attributes.
        def create_copy
          new_collection = ::Collection.new(@collection.attributes.except('id'))
          new_collection.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
          new_collection.save
          new_collection
        end

        ##
        # @function
        # Copies child collections and child works from @collection to a new collection.
        # @param {::Collection} collection_copy
        #   The collection to copy the children to.
        def copy_children(collection_copy)
          work_ids = []

          @collection.member_objects.each do |m|
            if m.collection?
              Hyrax::Collections::NestedCollectionPersistenceService.persist_nested_collection_for(
                parent: collection_copy,
                child: m
              )
            else
              work_ids << m.id
            end
          end

          collection_copy.add_member_objects(work_ids) unless work_ids.empty?
        end

        ##
        # @function
        # Copies parent collections from @collection to a new collection.
        # @param {::Collection} collection_copy
        #   The collection to copy the parents to.
        def copy_parents(collection_copy)
          unless @collection.parent_collections.empty?
            @collection.parent_collections.each do |parent|
              Hyrax::Collections::NestedCollectionPersistenceService.persist_nested_collection_for(
                parent: parent,
                child: collection_copy
              )
            end
          end
        end
    end
  end
end
