class TroveCollectionsController < Hyrax::Dashboard::CollectionsController
  # Don't want all the dashboard stuff in Trove Collection forms.
  with_themed_layout '1_column'

  def after_create
    additional_trove_after_create

    form
    set_default_permissions

    # if we are creating the new collection as a subcollection (via the nested collections controller),
    # we pass the parent_id through a hidden field in the form and link the two after the create.
    link_parent_collection(params[:parent_id]) unless params[:parent_id].nil?
    respond_to do |format|
      ActiveFedora::SolrService.instance.conn.commit
      format.html { redirect_to root_path, notice: t('hyrax.dashboard.my.action.collection_create_success') }
      format.json { render json: @collection, status: :created, location: trove_collection_path(@collection) }
    end
  end

  private

    ##
    # All the additional stuff we do to collections on the Trove application.
    def additional_trove_after_create
      # Trove collections are immediately public.
      @collection.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC

      # Need to set displays_in to trove.
      @collection.assign_attributes({'displays_in' => ['trove']})

      @collection.save
    end

    ##
    # Various parts of the controller access params[:controller], but since
    # we've extended the controller model, we need them to access params[:trove_controller].
    def collection_params
      params[:collection] = params[:trove_collection]
      super
    end
end
