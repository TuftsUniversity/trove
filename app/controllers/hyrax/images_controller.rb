# Generated via
#  `rails generate hyrax:work Image`
module Hyrax
  # Generated controller for Image
  class ImagesController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::Image

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::ImagePresenter

    # Finds a solr document matching the id and sets @presenter
    # @raise CanCan::AccessDenied if the document is not found or the user doesn't have access to it.
    def advanced
      @user_collections = user_collections

      respond_to do |wants|
        wants.html do
          presenter && parent_presenter
          render layout: "imageviewer"
        end
        wants.json do
          # load and authorize @curation_concern manually because it's skipped for html
          @curation_concern = _curation_concern_type.find(params[:id]) unless curation_concern
          authorize! :show, @curation_concern
          render :show, status: :ok
        end
      end
    end
  end
end
