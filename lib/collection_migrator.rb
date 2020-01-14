require File.join(Rails.root, 'app', 'helpers', 'collection_type_helper.rb')

module Tufts
  class CollectionMigrator
    extend CollectionTypeHelper

    ##
    # @function
    # Migrate a single trove collection.
    # @param {hash} old_coll
    #   The old collection hash.
    def self.migrate(old_coll)
      @old_coll = old_coll
      work_list = translate_list(@old_coll['member_ids_ssim']) unless @old_coll['member_ids_ssim'].nil?
      subcollection_list = translate_list(@old_coll['child_collections']) unless @old_coll['child_collections'].nil?

      puts "\n-----"
      puts "Migrating #{old_coll['title_tesim'].first} (#{old_coll['id']})"

      # Validate the stuff.
      return false unless valid?

      @new_coll = Collection.new
      set_metadata
      set_permissions

      set_child_collections(subcollection_list) if subcollection_list.present?

      @new_coll.add_member_objects(work_list) if work_list.present?

      if(@new_coll.save)
        puts "\nSuccessfully migrated #{@old_coll['title_tesim']} (#{@old_coll['id']}) to #{@new_coll.id}."
      else
        error("Failed to migrate from save!")
        return false
      end


      if(work_list.present?)
        puts "\nAdding work order to new collection."
        @new_coll.update_order(work_list, :work)
      end

      if(subcollection_list.present?)
        puts "\nAdding subcollection order to new collection."
        @new_coll.update_order(subcollection_list, :subcollection)
      end

      true
    end

    private

    ##
    # @function
    # Sets metadata on new collection, some data from old collection and some by default.
      def self.set_metadata
        @new_coll.assign_attributes({
                                     'displays_in' => ['trove'],
                                     'legacy_pid' => @old_coll['id']
                                   })

        @new_coll.title = @old_coll['title_tesim']
        @new_coll.description = @old_coll['description_tesim'] unless @old_coll['description_tesim'].nil?
        @new_coll.apply_depositor_metadata(@old_coll['creator_tesim'].first)

        # valid? has already checked that the old collection's model.
        if(@old_coll['active_fedora_model_ssi'] == 'CourseCollection')
          @new_coll.collection_type_gid = course_gid
          @new_coll.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
        else
          @new_coll.collection_type_gid = personal_gid
          @new_coll.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
        end

        # Substantially speeds up the migration.
        # https://github.com/samvera/hyrax/commit/ce8f9eadbd1bbcd8ca6bdabff2785000d08981e5
        @new_coll.reindex_extent = Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX
      end

      ##
      # @function
      # Sets the permissions and depositor info on new collection.
      def self.set_permissions
        user = User.find_or_create_system_user(@old_coll['creator_tesim'].first)
        Hyrax::Collections::PermissionsCreateService.create_default(collection: @new_coll, creating_user: user)
      end

      ##
      # @function
      # Translates the list of F3 member ids into F4 ids.
      def self.translate_list(f3_ids)
        f4_ids = []

        f3_ids.each do |id|
          new_record = translate_id(id)
          if(new_record.nil?)
            puts "Couldn't find #{id} - Removing from members."
            next
          else
            f4_ids << new_record.id
          end
        end

        f4_ids
      end

      ##
      # @function
      # Sets the child collections on parent collection.
      def self.set_child_collections(subcollection_ids)
        subcollection_ids.each do |id|
          subcollection = Collection.find(id)
          puts "Connecting child collection - #{subcollection} (#{subcollection.id})"
          Hyrax::Collections::NestedCollectionPersistenceService.persist_nested_collection_for(
            parent: @new_coll,
            child: subcollection
          )
        end
      end

      ##
      # @function
      # Get a F4 id from a F3 id.
      # @param {str} f3_id
      #   The legacy pid from Fedora 3.
      def self.translate_id(f3_id)
        ActiveFedora::Base.where("legacy_pid_tesim:\"#{f3_id}\"").first
      end

      ##
      # @function
      # Is this old collection valid for migration?
      def self.valid?
        # Check to see if this record displays in trove.
        if(@old_coll['displays_ssi'] != 'trove')
          error("#{@old_coll['displays_ssi']} isn't a Trove Collection")
          return false
        end

        # Check for a valid collection type.
        if(@old_coll['active_fedora_model_ssi'] != "PersonalCollection" &&
          @old_coll['active_fedora_model_ssi'] != "CourseCollection")
          error("#{@old_coll['active_fedora_model_ssi']} is not a valid collection type.")
          return false
        end

        # Check if this collection already exists in the repo.
        if(Collection.where("legacy_pid_tesim:\"#{@old_coll['id']}\"").count > 0)
          error("This record already exists in the repository.")
          return false
        end

        # Decided, for now, to migrate empty collections.
        # if(@old_coll['member_ids_ssim'].nil?)
        #   error("This collection doesn't have any subcollections or images.")
        #   return false
        # end

        true
      end

      ##
      # @function
      # Displays an error to console.
      # @param {str} msg
      #   The error message.
      def self.error(msg)
        puts "\n########### ERROR ############"
        puts "#{@old_coll['id']}: #{@old_coll['title_tesim']}"
        puts msg
        puts '##############################'
      end
  end
end
