# @file
# Patched to change filter_source to use POST, because queries are too large in dashboard/collections/collection_id pages
require_dependency Hyrax::Engine.root.join('app', 'models', 'concerns', 'hyrax', 'ability').to_s

module Hyrax
  module Ability
    extend ActiveSupport::Concern

    private
      # @return [Boolean] true if the user has at least one admin set they can deposit into.
      def admin_set_with_deposit?
        ids = PermissionTemplateAccess.for_user(ability: self,
                                                access: ['deposit', 'manage'])
                                      .joins(:permission_template)
                                      .pluck('DISTINCT source_id')
        query = "_query_:\"{!raw f=has_model_ssim}AdminSet\" AND {!terms f=id}#{ids.join(',')}"
        ActiveFedora::SolrService.count(query, method: :post).positive?
      end
  end
end
