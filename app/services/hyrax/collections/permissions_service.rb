require_dependency Hyrax::Engine.root.join('app', 'services', 'hyrax', 'collections', 'permissions_service').to_s

module Hyrax
  module Collections
    class PermissionsService
      # PATCH: Change filter_source to use POST, because queries are too large
      # in dashboard/collections/collection_id pages
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

      # PATCH: Fixing Dangerous query method that will not be in Rails 6.0.
      # Fixed in Hyrax 3.0 - can be removed when upgrading to that.
      def self.source_ids_for_user(access:, ability:, source_type: nil, exclude_groups: [])
        scope = PermissionTemplateAccess.for_user(ability: ability, access: access, exclude_groups: exclude_groups)
                                        .joins(:permission_template)
        ids = scope.select(:source_id).distinct.pluck(:source_id)
        return ids unless source_type
        filter_source(source_type: source_type, ids: ids)
      end
      private_class_method :source_ids_for_user


    end
  end
end
