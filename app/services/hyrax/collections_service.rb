require_dependency Hyrax::Engine.root.join('app', 'services', 'hyrax', 'collections_service').to_s

module Hyrax
 class CollectionsService
   # @param [Symbol] access :read or :edit
   def search_results(access)
     builder = list_search_builder('read')
     builder = builder.rows(10000) # Patching to get all collections
     response = context.repository.search(builder)
     response.documents
   end

   private

     def list_search_builder(access)
       list_search_builder_class.new(context)
                                .rows(1000) # Patching to get all collections
                                .with_access(access)
     end
 end
end