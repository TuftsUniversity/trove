##
# Adds an ordering mechanic to CollectionMemberService
class OrderedCollectionMemberSearchBuilder < Hyrax::CollectionMemberSearchBuilder

  self.default_processor_chain += [:order_documents, :no_extra_junk]

  # include filters into the query to only include the collection memebers
  def order_documents(solr_parameters)
    order = Collection.find(@collection.id).work_order

    if(order.present?)
      solr_parameters[:bq] ||= ''
      boost = order.count
      order.each do |id|
        solr_parameters[:bq] << "id:#{id}^#{boost} "
        boost -= 1
      end
      solr_parameters[:bq].strip!
    end
  end

  ##
  # I hate debugging these awful hyrax solr queries
  def no_extra_junk(solr_params)
    solr_params['facet'] = false
    solr_params.delete('facet.fields')
    solr_params.delete('facet.query')
    solr_params.delete('facet.pivot')
    solr_params.delete('hl.fl')
    solr_params.delete('stats')
    solr_params.delete('stats.field')
  end
end