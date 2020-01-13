##
# Same as Hyrax's CollectionMemberService, except we always get all works from Solr, for ordering purposes.
module Tufts
  class CollectionMemberService < Hyrax::Collections::CollectionMemberService

    private

      ##
      # set up an ordered member search builder for works only
      # @return [CollectionMemberSearchBuilder] new or existing
      def works_search_builder
        @works_search_builder ||= OrderedCollectionMemberSearchBuilder.new(scope: scope, collection: collection, search_includes_models: :works)
      end
  end
end