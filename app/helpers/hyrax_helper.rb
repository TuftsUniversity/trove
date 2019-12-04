require 'hyrax/name'

module HyraxHelper
  include ::BlacklightHelper
  include Hyrax::BlacklightOverride
  include Hyrax::HyraxHelperBehavior

  def sort_works(documents)
    if @collection.nil?
      if @presenter.nil?
        logger.error("ERROR: Couldn't find collection or presenter.")
        return documents
      end

      order = JSON.parse(Collection.find(@presenter.id).work_order)
    else
      order = JSON.parse(@collection.work_order)
    end

    if validate_matching_orders(order, documents)
      ordered_docs = []

      order.each do |id|
        documents.each do |doc|
          if doc.id == id
            ordered_docs << doc
            break
          end
        end
      end

      ordered_docs
    else
      documents
    end
  end

  def validate_matching_orders(order, documents)
    return false if order.nil?

    if order.count != documents.count
      logger.error("ERROR: CollectionOrder count does not match actual work count in collection.")
      return false
    end

    document_ids = documents.map { |d| d.id }
    if order.sort != document_ids.sort
      logger.error("ERROR: CollectionOrder ids don't match actual work ids in collection.")
      logger.error("Order: #{order}")
      logger.error("Documents: #{document_ids}")
      return false
    end

    true
  end

  ##
  # @function
  # Cuts a string down to size, unless the string is already short enough.
  # @param {hash} item
  #   Blacklight config passes an entire item hash to the function. Item[:value] should be the text we need.
  # @param {int} max_length
  #   The absolute max length a string can be. The function truncates to 15 characters less than this,
  #   to avoid deleting a single word, or some other unnecessary truncation.
  def limit_text_length(item, max_length = 150)
    # ordered_descriptions_ssim?
    return '' if item[:value].empty? || item[:value].first.empty?

    descrip = item[:value].first
    if (descrip.length <= max_length)
      return descrip
    end

    descrip.truncate(max_length - 15, separator: ' ')
  end
end
