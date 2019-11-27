require File.join(Rails.root, 'lib', 'collection_migrator.rb')

namespace :tufts do
  desc 'Migrates collections from Fedora3 to 4'
  task migrate_trove_collections: :environment do
    collections_dir = 'tmp/trove_collections'
    migrated_collections = []
    max_collections = 10000000000
    i = 0

    puts "\n\nStarting Migration"

    Dir["#{collections_dir}/*"].each do |file_path|
      if(i >= max_collections)
        break
      end

      old_coll = mtc_load_file(file_path)
      puts "\n\n\n-----------------------------------------"
      puts "Working on #{old_coll['id']}"

      # Skip if this collection has already been migrated.
      next if mtc_already_migrated?(old_coll['id'], migrated_collections)

      # is_leaf indicates that this collection has subcollections. Migrate all those first.
      if(old_coll['is_leaf'] && !old_coll['member_ids_ssim'].nil?)
        remove_from_members = [] # Ids to remove from the members array.
        old_coll['child_collections'] = [] # Save all valid child_collections to a new array.

        old_coll['member_ids_ssim'].each do |id|
          next unless id.include?('tufts.uc:') # Don't change non-collection members.

          remove_from_members << id # To remove collections from the member array.

          # Get the file path from the id.
          target_coll_file = File.join(
            Rails.root,
            collections_dir,
            "#{URI.encode(id, URI::PATTERN::RESERVED)}.json"
          )

          next unless mtc_file_exists?(target_coll_file, id) # If there's no file, ignore.

          old_coll['child_collections'] << id # Add id to new, child_collections array.

          # Migrate unless already migrated.
          unless(mtc_already_migrated?(id, migrated_collections))
            mtc_log_and_migrate(mtc_load_file(target_coll_file), migrated_collections)
          end
        end

        # Remove collections from the member array.
        remove_from_members.each { |id| old_coll['member_ids_ssim'].delete(id) }
      end

      # Migrate the parent collection (or collection without children).
      mtc_log_and_migrate(old_coll, migrated_collections)

      i = i + 1
    end
  end

  ##
  # Namespaced because we're in global.
  # Loads a collection json file.
  # @param {str} file_path
  #   The path to the file.
  def mtc_load_file(file_path)
    JSON.parse(File.read(file_path))
  end

  ##
  # Namespaced because we're in global.
  # Checks if an id is in the list and prints an error if so.
  # @param {str} id
  #   The id to check if it's already been migrated.
  # @param {arr} list
  #   The list of already migrated ids.
  def mtc_already_migrated?(id, list)
    if(list.include?(id))
      puts "\n#{id} has already been migrated."
      true
    else
      false
    end
  end

  ##
  # Namespaced because we're in global.
  # Checks if a collection json file exists and prints an error if not.
  # @param {str} file_path
  #   The path to the collection json file.
  # @param {str} id
  #   The id of the parent collection, for logging.
  def mtc_file_exists?(file_path, id)
    if(File.exist?(file_path))
      true
    else
      puts "#{id} doesn't have a file (#{file_path})!"
      false
    end
  end

  ##
  # Namespaced because we're in global.
  # Runs the CollectionMigrator on the collection and saves the id to the migrated_collections list.
  # @param {hash} coll
  #   The collection to be migrated.
  # @param {arr} migrated_coll_list
  #   The list of collections already migrated.
  def mtc_log_and_migrate(coll, migrated_coll_list)
    begin
      Tufts::CollectionMigrator.migrate(coll)
    rescue Ldp::Gone => e
      puts "LDP went down, waiting 10 seconds. (#{Time.new.inspect})"
      sleep(10)

      Tufts::CollectionMigrator.migrate(coll)
    end
    migrated_coll_list << coll['id']
  end
end
