##
# Functionality for both the dashboard and the non-dashboard CollectionsControllers
module TuftsCollectionControllerBehavior
  extend ActiveSupport::Concern
  include CollectionTypeHelpers

  ##
  # Copies collections, along with their child/parent collections, works, and work order.
  def copy
    new_collection = create_copy
    new_collection.collection_type_gid = personal_gid
    new_collection.save
    ActiveFedora::SolrService.instance.conn.commit

#    new_collection.update_order(@collection.work_order)

    ActiveFedora::SolrService.instance.conn.commit
    redirect_to root_path, notice: t('hyrax.dashboard.my.action.collection_create_success')
  end

  ##
  # Generates a PDF of all the images in the collection for user to donwload.
  def dl_pdf
    @curated_collection = ::Collection.find(params[:id])
    respond_to do |format|
      format.pdf do
        exporter = PdfCollectionExporter.new(@curated_collection)
        send_file(exporter.export, filename: exporter.pdf_file_name, type: "application/pdf")
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
                  type: "application/vnd.openxmlformats-officedocument.presentationml.presentation")
      end
    end
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