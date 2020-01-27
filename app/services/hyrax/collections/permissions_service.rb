# @file
# Patched to change filter_source to use POST, because queries are too large in dashboard/collections/collection_id pages
require_dependency Hyrax::Engine.root.join('app', 'services', 'hyrax', 'collections', 'permissions_service').to_s

module Hyrax
  module Collections
    class PermissionsService
      def self.filter_source(source_type:, ids:)
        return [] if ids.empty?
        id_clause = "{!terms f=id}#{ids.join(',')}"
        query = case source_type
                when 'admin_set'
                  "_query_:\"{!raw f=has_model_ssim}AdminSet\""
                when 'collection'
                  "_query_:\"{!raw f=has_model_ssim}Collection\""
                end
        query += " AND #{id_clause}"

        # Overwritten for Trove to use POST, because queries are too large
        ActiveFedora::SolrService.query(query, fl: 'id', rows: ids.count, method: :post).map do |hit|
          hit['id'] unless hit.empty?
        end
      end
      private_class_method :filter_source
    end
  end
end
