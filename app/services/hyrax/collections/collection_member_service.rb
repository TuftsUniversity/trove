require_dependency Hyrax::Engine.root.join('app', 'services', 'hyrax', 'collections', 'collection_member_service').to_s

module Hyrax
  module Collections
    class CollectionMemberService

      private

        # @api private
        #
        def query_solr(query_builder:, query_params:)
          per_page = query_params["per_page"].to_i
          #set when there is no default
          if per_page == 0
            per_page = 24
          end

          collection_id = query_params['id']
          order_obj = Tufts::Curation::CollectionOrder.where(collection_id: collection_id, item_type: :work).first

          if(order_obj.nil? || order_obj.order.nil?)
            return response
          end

          if(query_builder.class.to_s.include? 'OrderedCollectionMemberSearchBuilder')
            work_order = order_obj.order
            response = repository.search(query_builder.with(query_params).merge(rows: 1000).query)
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

            docs = docs[0..(per_page-1)]
            response["responseHeader"]["params"]["rows"] = per_page
            response["response"]["docs"] = docs
          else
            response = repository.search(query_builder.with(query_params).query)
          end

          response
        end
    end
  end
end
