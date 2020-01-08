##
# Functionality for both the dashboard and the non-dashboard CollectionsControllers
module TuftsCollectionControllerBehavior
  extend ActiveSupport::Concern
  include CollectionTypeHelpers

  ##
  # Copies collections, along with their works, and work order.
  # Copies are always private collections that belong to the copier.
  def copy
    new_collection = create_copy
    ActiveFedora::SolrService.instance.conn.commit

    copy_works(new_collection) if @collection.member_objects.present?
    set_permissions(new_collection)
    copy_work_order(new_collection) if @collection.work_order.present?

    redirect_to root_path, notice: t('hyrax.dashboard.my.action.collection_create_success')
  end

  ##
  # Generates a PDF of all the images in the collection for user to download.
  def dl_pdf
    @curated_collection = ::Collection.find(params[:id])
    respond_to do |format|
      format.pdf do
        exporter = PdfCollectionExporter.new(@curated_collection)
        send_file(exporter.export, filename: exporter.pdf_file_name, type: "application/pdf", :disposition => 'attachment')
      end
    end
  end

  ##
  # Generates a Powerpoint of all the images in the collection for user to donwload.
  def dl_powerpoint
    @curated_collection = ::Collection.find(params[:id])
    respond_to do |format|
      format.pptx do
        exporter = PowerPointCollectionExporter.new(@curated_collection)
        send_file(exporter.export,
                  filename: exporter.pptx_file_name,
                  type: "application/vnd.openxmlformats-officedocument.presentationml.presentation", :disposition => 'attachment')
      end
    end
  end

  private

    ##
    # Creates a copy of @collection. Transfers metadata. Sets defaults. Commits to Solr so we can move forward.
    def create_copy
      new_collection = ::Collection.new(@collection.attributes.except('id', 'collection_type_gid', 'depositor', 'legacy_pid'))
      new_collection.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
      new_collection.collection_type_gid = personal_gid
      new_collection.apply_depositor_metadata(current_user.user_key)
      new_collection.save
      new_collection
    end

    ##
    # Copies works from @collection to new_collection.
    # @param {Collection} new_collection
    #   The collection to copy the works into.
    def copy_works(new_collection)
      work_ids = []
      @collection.member_objects.each do |m|
        work_ids << m.id unless m.collection?
      end
      new_collection.add_member_objects(work_ids) unless work_ids.empty?
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
