namespace :tufts do
  desc 'Migrates collections from Fedora3 to 4'
  task migrate_trove_collections: :environment do
    collections_dir = 'tmp/trove_collections/*'
    personal_gid = Hyrax::CollectionType.where(title: "Personal Collection").first.gid
    course_gid = Hyrax::CollectionType.where(title: "Course Collection").first.gid

    puts "\n\nStarting Migration"

    Dir[collections_dir].each do |file_path|
      json = File.read(file_path)
      old_coll = JSON.parse(json)

      if(old_coll['displays_ssi'] != 'trove')
        puts "\n\n#{old_coll['id']}: #{old_coll['title_tesim']} isn't a Trove Collection"
        byebug
        next
      end

      new_coll = Collection.new
      new_coll.assign_attributes({
        'displays_in' => ['trove'],
        'legacy_pid' => old_coll['id']
      })
      new_coll.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      new_coll.title = old_coll['title_tesim']
      new_coll.description = old_coll['description_tesim'] unless old_coll['description_tesim'].nil?
      new_coll.apply_depositor_metadata(old_coll['creator_tesim'].first)

      if(old_coll['active_fedora_model_ssi'] == 'PersonalCollection')
         new_coll.collection_type_gid = personal_gid
      elsif(old_coll['active_fedora_model_ssi'] == 'CourseCollection')
         new_coll.collection_type_gid = course_gid
      else
        puts "#{old_coll['active_fedora_model_ssi']} is not a valid collection type."
        byebug
        break
      end

      old_coll.each do |k,v|
        puts "#{k}: #{v}"
      end

      byebug
      break
    end
  end
end
