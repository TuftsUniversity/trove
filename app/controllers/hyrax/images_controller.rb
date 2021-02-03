# Generated via
#  `rails generate hyrax:work Image`
require 'byebug'
module Hyrax
  # Generated controller for Image
  class ImagesController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::Image

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::ImagePresenter

    def show
      referer = request.referer
      unless referer.nil?
        match_data = referer.match /(trove\-\w{9})/

        unless match_data.nil?
          id = match_data[0]
          resp = ActiveFedora::SolrService.get("id:#{id}")
          doc = resp['response']['docs'].first
          collection_title = doc["title_tesim"].first
          add_breadcrumb "#{collection_title}", "/collections/#{id}", :title => "#{collection_title}"
        end
      end

      super

    end
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

    def manifest
      headers['Access-Control-Allow-Origin'] = '*'

      json = iiif_manifest_builder.manifest_for(presenter: iiif_manifest_presenter)
      json['metadata'] ||= []
      json['metadata'] << {
        'label' => I18n.t('copyright_acknowledgement.label'),
        'value' => [I18n.t('copyright_acknowledgement.value')]
      }

      respond_to do |wants|
        wants.json { render json: json }
        wants.html { render json: json }
      end
    end
  end
end
