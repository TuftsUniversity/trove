##
# Same as Hyrax's CollectionMemberService, except we always get all works from Solr, for ordering purposes.
module Tufts
  class CollectionMemberService < Hyrax::Collections::CollectionMemberService

    private

    ##
    # The default search pattern
    def orderless_search(query_builder, query_params)
      repository.search(query_builder.with(query_params).query)
    end

    ##
    # Applies our custom sort to the work search results
    def query_solr(query_builder:, query_params:)
      # Default on subcollection (or any non-work) search
      if(query_builder.search_includes_models != :works)
        return orderless_search(query_builder, query_params)
      end

      # Default on work searches without orders
      collection_id = query_params['id']
      order_obj = Tufts::Curation::CollectionOrder.where(collection_id: collection_id, item_type: :work).first
      if(order_obj.nil? || order_obj.order.blank?)
        return orderless_search(query_builder, query_params)
      end

      per_page = query_params["per_page"].to_i
      
      #set when there is no default
      if per_page == 0
        per_page = 24
      end

      page_number = query_params["page"]
      
      if page_number.nil?
        page_number = 1
      else
        page_number = page_number.to_i
      end

      work_order = order_obj.order

      query_params["start"] = "0"
      query_params["page"] = 1
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
      
      if page_number == 1
        offset_start = 0
      else
        offset_start = (page_number * per_page) - per_page
      end

      offset_end = offset_start + (per_page-1)

      docs = docs[offset_start..offset_end]
      
      response["responseHeader"]["params"]["rows"] = per_page
      response["responseHeader"]["params"]["page"] = page_number
      response["responseHeader"]["params"]["start"] = offset_start
      response["response"]["docs"] = docs

      response
    end
  end
end