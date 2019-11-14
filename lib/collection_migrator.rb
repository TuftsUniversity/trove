module Tufts
  class CollectionMigrator

    ##
    # @function
    # Migrate a single trove collection.
    # @param {hash} old_coll
    #   The old collection hash.
    def self.migrate(old_coll)
      begin
        @old_coll = old_coll

        puts "\n-----"
        puts "Migrating #{old_coll['title_tesim'].first} (#{old_coll['id']})"

        # Validate the stuff.
        return false unless valid?

        @new_coll = Collection.new
        set_metadata

        set_child_collections unless @old_coll['child_collections'].nil?

        unless(@old_coll['member_ids_ssim'].nil?)
          work_list = build_member_list
          @new_coll.add_member_objects(work_list)
        end

        if(@new_coll.save)
          puts "\nSuccessfully migrated #{@old_coll['title_tesim']} (#{@old_coll['id']}) to #{@new_coll.id}."
        else
          error("Failed to migrate from save!")
          return false
        end

        puts "\nAdding work order to new collection."
        Tufts::Curation::CollectionOrder.new(collection_id: @new_coll.id).save
        @new_coll.update_work_order(work_list) unless work_list.nil?

        true
      rescue StandardError => e
        error("Failed to migrate with exception: #{e}")
        return false
      end
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
        @new_coll.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
        @new_coll.title = @old_coll['title_tesim']
        @new_coll.description = @old_coll['description_tesim'] unless @old_coll['description_tesim'].nil?
        @new_coll.apply_depositor_metadata(@old_coll['creator_tesim'].first)
        # valid? has already checked that the old collection's model is one of these two.
        @new_coll.collection_type_gid = @old_coll['active_fedora_model_ssi'] == 'PersonalCollection' ? personal_gid : course_gid

        # Substantially speeds up the migration.
        # https://github.com/samvera/hyrax/commit/ce8f9eadbd1bbcd8ca6bdabff2785000d08981e5
        @new_coll.reindex_extent = Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX
      end

      ##
      # @function
      # Translates the list of F3 member ids into F4 ids.
      def self.build_member_list
        puts "Building Member List"
        f4_ids = []

        @old_coll['member_ids_ssim'].each do |id|
          new_record = translate_id(id)
          if(new_record.nil?)
            puts "Couldn't find #{id}!"
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
      def self.set_child_collections
        @old_coll['child_collections'].each do |id|
          child_collection = translate_id(id)
          if(child_collection.nil?)
            puts "Couldn't find child collection: #{new_id}"
            next
          end

          puts "Connecting child collection - #{child_collection} (#{child_collection.id})"
          Hyrax::Collections::NestedCollectionPersistenceService.persist_nested_collection_for(
            parent: @new_coll,
            child: child_collection
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

      ##
      # @function
      # Gets the Personal Collection gid from the db.
      def self.personal_gid
        @personal_gid ||= Hyrax::CollectionType.where(title: "Personal Collection").first.gid
      end

      ##
      # @function
      # Gets the Course Collection gid from the db.
      def self.course_gid
        @course_gid ||= Hyrax::CollectionType.where(title: "Course Collection").first.gid
      end
    end
end
