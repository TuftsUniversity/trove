##
# Functionality for both the dashboard and the non-dashboard CollectionsControllers
module TuftsCollectionControllerBehavior
  extend ActiveSupport::Concern
  include CollectionTypeHelper

  included do
    # The search builder to find the collections' members
    self.membership_service_class = Tufts::CollectionMemberService
  end

  ##
  # Copies collections, along with their works, and work order.
  # Copies are always private collections that belong to the copier.
  def copy
    new_collection = create_copy
    ActiveFedora::SolrService.instance.conn.commit

    set_permissions(new_collection)
    copy_work_order(new_collection) if @collection.work_order.present?

    if(Rails.env == "test")
      AddWorksToCollectionJob.perform_now(only_work_ids, new_collection.id) if only_work_ids.present?
    else
      AddWorksToCollectionJob.perform_later(only_work_ids, new_collection.id) if only_work_ids.present?
    end

    redirect_to root_path, notice: t('hyrax.dashboard.my.action.collection_create_success')
  end

  ##
  # Generates a PDF of all the images in the collection for user to download.
  def dl_pdf
    @collection = ::Collection.find(params[:id])
    respond_to do |format|
      format.pdf do
        export_manager = Tufts::ExportManagerService.new(@collection, 'pdf')
        send_file(export_manager.retrieve_asset,
                  filename: export_manager.readable_filename,
                  type: "application/pdf",
                  disposition: 'attachment'
        )
      end
    end
  end

  ##
  # Generates a Powerpoint of all the images in the collection for user to download.
  def dl_powerpoint
    @collection = ::Collection.find(params[:id])
    respond_to do |format|
      format.pptx do
        export_manager = Tufts::ExportManagerService.new(@collection, 'pptx')
        send_file(export_manager.retrieve_asset,
                  filename: export_manager.readable_filename,
                  type: "application/vnd.openxmlformats-officedocument.presentationml.presentation",
                  disposition: 'attachment'
        )
      end
    end
  end

  private

    ##
    # Creates a copy of @collection. Transfers metadata. Sets defaults. Commits to Solr so we can move forward.
    def create_copy(type = 'personal')
      new_collection = ::Collection.new(@collection.attributes.except('id', 'collection_type_gid', 'depositor', 'legacy_pid'))

      # Default to making personal collections. Only make a course collection if 'course' is passed as type.
      if(type == 'course')
        new_collection.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
        new_collection.collection_type_gid = course_gid
      else
        new_collection.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
        new_collection.collection_type_gid = personal_gid
      end

      new_collection.apply_depositor_metadata(current_user.user_key)
      new_collection.save
      new_collection
    end

    ##
    # Filters out collections from member_objects and returns an array of just work ids.
    def only_work_ids
      @only_works ||= @collection.member_objects.select { |m| !m.collection? }.collect(&:id)
    end

    ##
    # Sets permissions on @new_collection
    def set_permissions(new_collection)
      Hyrax::Collections::PermissionsCreateService.create_default(collection: new_collection, creating_user: current_user)
    end

    ##
    # Copies the work order from @collection to @new_collection.
    def copy_work_order(new_collection)
      new_collection.update_order(@collection.work_order, :work)
    end
end
