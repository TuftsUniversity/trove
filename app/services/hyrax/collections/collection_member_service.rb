module Hyrax
  module Collections
    # Responsible for retrieving collection members
    class CollectionMemberService
      attr_reader :scope, :params, :collection
      delegate :repository, to: :scope

      # @param scope [#repository] Typically a controller object which responds to :repository
      # @param [Collection]
      # @param [ActionController::Parameters] query params
      def initialize(scope:, collection:, params:)
        @scope = scope
        @collection = collection
        @params = params
      end

      # @api public
      #
      # Collections which are members of the given collection
      # @return [Blacklight::Solr::Response] {up to 50 solr documents}
      def available_member_subcollections
        query_solr(query_builder: subcollections_search_builder, query_params: params_for_subcollections)
      end

      # @api public
      #
      # Works which are members of the given collection
      # @return [Blacklight::Solr::Response]
      def available_member_works
       # byebug
        #works_search_builder.start = 0
        #works_search_builder.rows = 24
        query_solr(query_builder: works_search_builder, query_params: params)
      end

      # @api public
      #
      # Work ids of the works which are members of the given collection
      # @return [Blacklight::Solr::Response]
      def available_member_work_ids
        query_solr_with_field_selection(query_builder: work_ids_search_builder, fl: 'id')
      end

      private

        # @api private
        #
        # set up a member search builder for works only
        # @return [CollectionMemberSearchBuilder] new or existing
        def works_search_builder
          @works_search_builder ||= Hyrax::CollectionMemberSearchBuilder.new(scope: scope, collection: collection, search_includes_models: :works)
        end

        # @api private
        #
        # set up a member search builder for collections only
        # @return [CollectionMemberSearchBuilder] new or existing
        def subcollections_search_builder
          @subcollections_search_builder ||= Hyrax::CollectionMemberSearchBuilder.new(scope: scope, collection: collection, search_includes_models: :collections)
        end

        # @api private
        #
        # set up a member search builder for returning work ids only
        # @return [CollectionMemberSearchBuilder] new or existing
        def work_ids_search_builder
          @work_ids_search_builder ||= Hyrax::CollectionMemberSearchBuilder.new(scope: scope, collection: collection, search_includes_models: :works)
        end

        # @api private
        #
        def query_solr(query_builder:, query_params:)                    
          #Rails.logger.warn "PRERESPONSE : #{query_builder}"
          #Rails.logger.warn "PRERESPONSE : #{query_params}"
          per_page = query_params["per_page"].to_i
          
          #set when there is no default
          if per_page == 0
            per_page = 24
          end

          
          collection_id = query_params['id']
          
          # slow
          #collection = Collection.find(collection_id)
          
          # faster
          collection = Tufts::Curation::CollectionOrder.where(collection_id: collection_id, item_type: :work).first

          #byebug
          
          if !collection.nil? && query_builder.class.to_s.include? 'OrderedCollectionMemberSearchBuilder'
            work_order = collection.order
            response = repository.search(query_builder.with(query_params).merge(rows: 1000).query)
          #  byebug
            docs = response["response"]["docs"]
            docs = docs.sort_by do |e|
              id = e["id"] 
              
              tag_to_end = 0
              if id.nil?                
                sort = work_order.length + tag_to_end
                tag_to_end +=1
              else
                if work_order.index(id).nil?
                  sort = work_order.length + tag_to_end
                  tag_to_end +=1
                 else
                  sort = work_order.index(id) 
                 end
              end
              sort
            end          
            #byebug
            docs = docs[0..(per_page-1)]
            response["responseHeader"]["params"]["rows"] = per_page
            response["response"]["docs"] = docs
          else
            response = repository.search(query_builder.with(query_params).query)
          end
          #Rails.logger.warn "RESPONSE : #{query_builder}"
          #Rails.logger.warn "RESPONSE : #{query_params}"
          #Rails.logger.warn "RESPONSE : #{response}"
          #byebug
          response
          
          
        end

        # @api private
        #
        def query_solr_with_field_selection(query_builder:, fl:)
          repository.search(query_builder.merge(fl: fl).query)
          

        end

        # @api private
        #
        # Blacklight pagination still needs to be overridden and set up for the subcollections.
        # @return <Hash> the additional inputs required for the subcollection member search builder
        def params_for_subcollections
          # To differentiate current page for works vs subcollections, we have to use a sub_collection_page
          # param. Map this to the page param before querying for subcollections, if it's present
          params[:page] = params.delete(:sub_collection_page)
          params
        end
    end
  end
end
