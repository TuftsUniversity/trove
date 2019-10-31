namespace :tufts do
  desc 'Migrates collections from Fedora3 to 4'
  task migrate_trove_collections: :environment do
    collections_dir = 'tmp/trove_collections/*'
    personal_gid = Hyrax::CollectionType.where(title: "Personal Collection").first.gid
    course_gid = Hyrax::CollectionType.where(title: "Course Collection").first.gid

    max_collections = 1
    i = 0
    skip = true

    puts "\n\nStarting Migration"

    Dir[collections_dir].each do |file_path|
      if skip
        skip = false
        next
      end


      if(i >= max_collections)
        break
      else
        i = i + 1
      end

      json = File.read(file_path)
      old_coll = JSON.parse(json)

      if(old_coll['displays_ssi'] != 'trove')
        puts "\n\n#{old_coll['id']}: #{old_coll['title_tesim']} isn't a Trove Collection"
        byebug
        next
      else
        puts "\nWorking on #{old_coll['title_tesim'].first} (#{old_coll['id']})"
      end

      new_coll = Collection.new

      mtc_transfer_metadata(old_coll, new_coll)

      if(old_coll['active_fedora_model_ssi'] == 'PersonalCollection')
         new_coll.collection_type_gid = personal_gid
      elsif(old_coll['active_fedora_model_ssi'] == 'CourseCollection')
         new_coll.collection_type_gid = course_gid
      else
        puts "#{old_coll['active_fedora_model_ssi']} is not a valid collection type."
        byebug
        next
      end

      #mtc_build_member_list(old_coll['member_ids_ssim'])
      #new_coll.add_member_objects(mtc_build_member_list(old_coll['member_ids_ssim']))

      puts new_coll.save!

      #begin
        # unless new_coll.save
        #   puts "ERROR couldn't save collection!"
        #   byebug
        #   next
        # end
      #rescue
      #  byebug
      #  next
      #end

      #Tufts::Curation::CollectionOrder.new(collection_id: new_coll.id).save
      #new_coll.update_work_order(old_coll['member_ids_ssim'])

    end
  end

  ##
  # @function
  # Namespaced bcause this is in global scope.
  # Sets metadata on new collection, some data from old collection and some by default.
  def mtc_transfer_metadata(old_coll, new_coll)
    new_coll.assign_attributes({
      'displays_in' => ['trove'],
      'legacy_pid' => old_coll['id']
    })
    new_coll.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    new_coll.title = old_coll['title_tesim']
    new_coll.description = old_coll['description_tesim'] unless old_coll['description_tesim'].nil?
    new_coll.apply_depositor_metadata(old_coll['creator_tesim'].first)
  end

  ##
  # @function
  # Namespaced bcause this is in global scope.
  # Translates the list of F3 ids into F4 ids.
  def mtc_build_member_list(f3_ids)
    puts "Building Member List"
    f4_ids = []
    f3_ids.each do |id|
      f4_ids << ActiveFedora::Base.where("legacy_pid_tesim:\"#{id}\"").first.id
    end

    f4_ids
  end
end
