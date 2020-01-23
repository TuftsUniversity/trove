require_dependency Hyrax::Engine.root.join('app', 'indexers', 'hyrax', 'repository_reindexer').to_s

module Hyrax
  module RepositoryReindexer
    module ClassMethods
      # overrides https://github.com/samvera/active_fedora/blob/master/lib/active_fedora/indexing.rb#L95-L125
      # see implementation details in adapters/nesting_index_adapter.rb#each_perservation_document_id_and_parent_ids
      def reindex_everything(*)
        #Samvera::NestingIndexer.reindex_all!(extent: Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX)
      end
    end
  end
end

ActiveFedora::Base.module_eval { include Hyrax::RepositoryReindexer }
