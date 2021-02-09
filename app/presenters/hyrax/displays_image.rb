require_dependency Hyrax::Engine.root.join('app', 'presenters', 'hyrax', 'displays_image').to_s

module Hyrax
  module DisplaysImage
    extend ActiveSupport::Concern

    # PATCH: Changes width and height to use actual image width and height, instead of pre-set values.
    def display_image
      return nil unless solr_document.image? && current_ability.can?(:read, solr_document)
      return nil unless latest_file_id

      # @see https://github.com/samvera-labs/iiif_manifest
      IIIFManifest::DisplayImage.new(display_image_url(request.base_url),
                                     format: image_format(alpha_channels),
                                     width: original_file.width.empty? ? 50000 : original_file.width.first,
                                     height: original_file.height.empty? ? 50000 : original_file.height.first,
                                     iiif_endpoint: iiif_endpoint(latest_file_id))
    end
  end
end
