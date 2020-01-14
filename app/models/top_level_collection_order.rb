class TopLevelCollectionOrder < ::ActiveRecord::Base
  extend CollectionTypeHelper

  validates :user_id, presence: true, uniqueness: true

  # The user_id used to save the top level Course Collection order
  class_attribute :course_collection_id
  self.course_collection_id = 'courses'

  ##
  # Gets user's order
  # @param {int} user_id
  #   The user's id
  def self.search_by_user(user_id)
    o = order_obj(user_id)
    o.nil? ? [] : o.order
  end

  ##
  # Sets a user's order
  # @param {int} user_id
  #   The user's id
  # @param {arr} order
  #   The order of collection ids
  def self.set_for_user(user_id, order)
    o = order_obj(user_id)

    if(o.nil?)
      if(User.exists?(user_id))
        create!(user_id: user_id, order: clean(order, user_id))
      else
        Rails.logger.warn("Tried to set TopLevelCollectionOrder for non-user: #{user_id}")
      end
    else
      o.order = clean(order, user_id)
    end
  end

  ##
  # Gets the top level course collections order for the sidebar
  def self.course_collection_order
    search_by_user(course_collection_id)
  end

  ##
  # Set the top level course collections in the sidebar
  # @param {arr} order
  #   The ids in the order for the course collections in the sidebar
  def self.set_course_collection_order(order)
    set_for_user(course_collection_id, order)
  end

  private

    ##
    # Gets a record via user_id
    # @param {int} user_id
    #   The user's id.
    def self.order_obj(user_id)
      where(user_id: user_id).first!
    rescue StandardError
      nil
    end

    ##
    # Removes any ids from list that don't match ids in query
    # @param {arr} order
    #   The order of ids to verify
    # @param {int} user_id
    #   The id of the user whose collections we need
    def self.clean(order, user_id)
      valid_ids = possible_ids(user_id)
      order.select {|id| valid_ids.include?(id) }
    end

    ##
    # All the ids that are top level course collections
    # @param {int/nil} user_id
    #   The id of the user whose collections we need, or nil for course collections
    def self.possible_ids(user_id)
      query = []
      query << "\+has_model_ssim:Collection"
      query << "\+displays_in_tesim:trove"
      query << "-member_of_collection_ids_ssim:*"

      if(user_id == course_collection_id)
        query << "\+collection_type_gid_ssim:\"#{course_gid}\""
      else
        username = User.find(user_id).username
        query << "\+depositor_tesim:#{username}"
        query << "\+collection_type_gid_ssim:\"#{personal_gid}\""
      end

      results = ActiveFedora::SolrService.get(query.join(" "), { rows:1000, fl:'id' })
      results['response']['docs'].map {|o| o['id']}
    end
end
