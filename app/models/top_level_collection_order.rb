class TopLevelCollectionOrder < ::ActiveRecord::Base
  extend CollectionTypeHelper

  validates :user_id, presence: true, uniqueness: true

  # The user_id used to save the top level Course Collection order
  class_attribute :course_collection_id
  self.course_collection_id = 'courses'

  ##
  # Gets the top level course collections order for the sidebar
  def self.get_course_collection_order
    course_collection_order_obj.order
  end

  ##
  # Set the top level course collections in the sidebar
  def self.set_course_collection_order(order)
    course_collection_order_obj.order = clean(order)
  end

  ##
  # The TopLevelCollectionOrder object that contains the top level sidebar course collection order
  def self.course_collection_order_obj
    @course_collection_order_obj ||= where(user_id: course_collection_id).first
  end


  private

    ##
    # Removes any ids from list that don't match ids in query
    # @param {arr} order
    #   The order of ids to verify
    def self.clean(order)
      possible_ids = all_top_level_course_collection_ids
      order.select {|id| possible_ids.include?(id) }
    end

    ##
    # All the ids that are top level course collections
    def self.all_top_level_course_collection_ids
      model_q = "\+has_model_ssim:Collection"
      type_q = "\+collection_type_gid_ssim:\"#{course_gid}\""
      only_trove = "\+displays_in_tesim:trove"
      no_subs = "-member_of_collection_ids_ssim:*"
      q = " #{only_trove} #{model_q} #{type_q} #{no_subs}"
      results = ActiveFedora::SolrService.get(q, { rows:1000, fl:'id' })
      results['response']['docs'].map {|o| o['id']}
    end
end
