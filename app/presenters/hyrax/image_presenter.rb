require 'byebug'
include CollectionTypeHelper

# Generated via
#  `rails generate hyrax:work Image`
module Hyrax
  class ImagePresenter < Hyrax::WorkShowPresenter

    def genre
      solr_document[:genre_tesim]
    end

    def member_of_collection_ids
      solr_document[:member_of_collection_ids_ssim]
    end

    # IIIF metadata for inclusion in the manifest
    #  Called by the `iiif_manifest` gem to add metadata
    #
    # @return [Array] array of metadata hashes
    def manifest_metadata
      metadata = []      
   
      metadata << {
        'label' => "Usage Information",
        'value' => [I18n.t('copyright_acknowledgement')]
      }
      metadata
    end

    ##
    # @function
    # Returns a hash of course and personal collections that this image is a member of.
    # @return {hash}
    #   { course: {id: title, id title}, personal: {id: title, id: title} }
    def associated_collections
      [] if member_of_collection_ids.nil? || member_of_collection_ids.empty?

      collections = {
        course: {},
        personal: {}
      }

      Collection.where(
        id: member_of_collection_ids,
        collection_type_gid_ssim: course_gid
      ).each do |c|
        collections[:course][c.id] = c.title.first
      end

      collections[:course] = collections[:course].sort_by { |id,title| title}

      Collection.where(
        id: member_of_collection_ids,
        collection_type_gid_ssim: personal_gid
      ).each do |c|
        collections[:personal][c.id] = c.title.first
      end

      collections[:personal] = collections[:personal].sort_by { |id,title| title}

      collections
    end
  end
end
