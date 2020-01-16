require_dependency Hyrax::Engine.root.join('app', 'controllers', 'hyrax', 'dashboard', 'collections_controller').to_s
require 'sipity/entity' # Required for add_item_to_collection to work

module Hyrax
  module Dashboard
    ## Shows a list of all collections to the admins
    class CollectionsController < Hyrax::My::CollectionsController
      include TuftsCollectionControllerBehavior
      with_themed_layout '1_column'

      ##
      # Overwrites collection create method to add various customizations for trove.
      def create
        # Manual load and authorize necessary because Cancan will pass in all
        # form attributes. When `permissions_attributes` are present the
        # collection is saved without a value for `has_model.`
        @collection = ::Collection.new
        authorize! :create, @collection
        # Coming from the UI, a collection type gid should always be present.  Coming from the API, if a collection type gid is not specified,
        # use the default collection type (provides backward compatibility with versions < Hyrax 2.1.0)
        @collection.collection_type_gid = params[:collection_type_gid].presence || default_collection_type.gid
        @collection.attributes = collection_params.except(:members, :parent_id, :collection_type_gid)
        @collection.assign_attributes({'displays_in' => ['trove']}) # Added for Trove
        @collection.apply_depositor_metadata(current_user.user_key)
        add_members_to_collection unless batch.empty?
        @collection.visibility = @collection.collection_type_gid == helpers.course_gid ?
          Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC :
          Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE # Changed for Trove
        if @collection.save
          after_create
        else
          after_create_error
        end
      end

      ##
      # @function
      # Overwrites collection after_create callback to redirect to root, instead of dashboard.
      def after_create
        form
        set_default_permissions

        # if we are creating the new collection as a subcollection (via the nested collections controller),
        # we pass the parent_id through a hidden field in the form and link the two after the create.
        link_parent_collection(params[:parent_id]) unless params[:parent_id].nil?

        respond_to do |format|
          ActiveFedora::SolrService.instance.conn.commit
          format.html { redirect_to root_path, notice: t('hyrax.dashboard.my.action.collection_create_success') } #Changed for trove
          format.json { render json: @collection, status: :created, location: root_path(@collection) }
        end
      end

      ##
      # Creates a Course Collection copy of a Personal Collection. Only for admin use.
      def upgrade
        unless(is_personal_collection?(@collection))
          redirect_to root_path, notice: t('trove_collections.additional_actions.notices.not_personal_collection')
        end

        new_collection = create_copy('course')
        ActiveFedora::SolrService.instance.conn.commit

        set_permissions(new_collection)
        copy_work_order(new_collection) if @collection.work_order.present?
        AddWorksToCollectionJob.perform_later(only_work_ids, new_collection.id) if only_work_ids.present?

        redirect_to root_path, notice: t('trove_collections.additional_actions.notices.upgrade_success')
      end

      ##
      # Overwriting to redirect to home page, instead of dashboard.
      def after_destroy(_id)
        # leaving id to avoid changing the method's parameters prior to release
        respond_to do |format|
          format.html do
            redirect_to root_path, # Changed for Trove
                        notice: t('hyrax.dashboard.my.action.collection_delete_success')
          end
          format.json { head :no_content, location: root_path }
        end
      end

      ##
      # Responds to an ajax call and updates the work order
      def update_work_order
        #byebug
        per_page = params[:per_page]
        page = params[:page]
        
        #null checks for defaults
        if page == "null"
          page = 1
        else
          page = page.to_i
        end

        if per_page == "null"
          per_page = 24
        else
          per_page = per_page.to_i
        end

        # TODO: There should be a faster way to figure out the length of the collection        
        #byebug
        #resp = ActiveFedora::SolrService.get("id:#{fs_id}")

        # slow
        # number_of_works = @collection.member_works.length

        # fast?
        number_of_works = ActiveFedora::Base.where("member_of_collection_ids_ssim:#{@collection.id} AND has_model_ssim:Image").count
        # we're only updating a page at time in theory so get the subset of the array we're updating
        items_to_update = JSON.parse(params[:order])

        # get the whole work order, although, this is misleading as there isn't necessarily a work order for the 
        # the whole collection there could be none or just 1 or a page of a collection, so this is kinda shit
        # TODO: if you had 3 pages and set a work order on page 1 and 3 and never set an order on page 2 i think you'd have 
        # an issue here
        full_collection_order = @collection.work_order

        # number of items in this update
        number_to_update = items_to_update.length

        # the starting offset of the page to merge this is into the overall array
        initial_offset = page == 1 ? 0 : (page - 1) * per_page

        # the ending offset of the page to merge this into the array corrected for the end of the collection
        ending_offset = page * per_page > number_of_works ? number_of_works : page * per_page
        #byebug

        #update the overall collection
        full_collection_order[initial_offset,ending_offset] = items_to_update
        
        #persist
        @collection.update_order(full_collection_order, :work)
      end

      ##
      # Responds to an ajax call to add an item to a collection
      def add_item_to_collection
        return false unless(validate_collection_and_user(params[:username]))
        @collection.add_member_objects(params[:image])
      rescue StandardError => e
        Rails.logger.debug("\n\n\n\n\n\n")
        logger.error e.message
        logger.error e.backtrace.join("\n")
        Rails.logger.debug("\n\n\n\n\n\n")
      end

      private

      ##
      # Validates that this user can change this collection
      # TODO replace with cancan ideally
      def validate_collection_and_user(username)
        user = ::User.where(username: username).first!

        # Admins can do it all
        if(user.admin?)
          return true
        end
        # Non-admin means no course collections
        if(is_course_collection?(@collection))
          return false
        end
        # Gotta own the personal collection
        if(@collection.depositor != username)
          return false
        end

        true
      rescue StandardError
        false
      end
    end
  end
end
