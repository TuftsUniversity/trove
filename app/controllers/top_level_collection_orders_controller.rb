# Sets the order for top-level collections using the TopLevelCollectionOrder model.
class TopLevelCollectionOrdersController < ApplicationController
  def set_course_order
    return if params[:order].blank?
    order = JSON.parse(params[:order])
    TopLevelCollectionOrder.set_course_collection_order(order)
    Rails.cache.delete 'views/collections-sidebar-courses'
  end

  def set_personal_order
    return if params[:order].blank? || params[:id].blank?
    order = JSON.parse(params[:order])
    TopLevelCollectionOrder.set_for_user(params[:id], order)
    Rails.cache.delete 'views/collections-sidebar-courses'
  end
end