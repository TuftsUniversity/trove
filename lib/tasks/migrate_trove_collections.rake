require File.join(Rails.root, 'lib', 'collection_migrator.rb')

namespace :tufts do
  desc 'Migrates collections from Fedora3 to 4'
  task migrate_trove_collections: :environment do
    collections_dir = 'tmp/trove_collections'

    puts "\n\nStarting Migration"

    Dir["#{collections_dir}/*"].each do |file_path|
      coll = mtc_load_file(file_path)
      mtc_process_collection(coll, collections_dir)
    end
  end


  ##
  # Migrates a collection and recursively migrates any children it may have.
  # @param {hash} coll
  #  The collection hash from JSON.
  # @param {str} collections_dir
  #   The directory that all the collection json files are in.
  def mtc_process_collection(coll, collections_dir)
    puts "\n\n\n-----------------------------------------"
    puts "Working on #{coll['id']}"

    # is_leaf indicates that this collection has subcollections. Migrate all those first.
    if(coll['is_leaf'] && !coll['member_ids_ssim'].nil?)
      coll = mtc_process_subcollections(coll, collections_dir)
    end

    # Migrate the parent collection (or collection without children).
    mtc_log_and_migrate(coll)
  end

  ##
  # Migrates all the subcollections in a parent collection.
  # @param {hash} parent_coll
  #   The parent collection hash.
  # @param {str} collections_dir
  #   The directory that all the collection json files are in.
  def mtc_process_subcollections(parent_coll, collections_dir)
    puts "\n--------------"
    puts "Processing subcollections\n\n"

    remove_from_members = [] # Ids to remove from the members array.
    parent_coll['child_collections'] = [] # Save all valid child_collections to a new array.

    parent_coll['member_ids_ssim'].each do |id|
      next unless id.include?('tufts.uc:') # Don't change non-collection members.

      remove_from_members << id # To remove collections from the member array.

      # Get the file path from the id.
      target_coll_file = File.join(
        Rails.root,
        collections_dir,
        "#{URI.encode(id, URI::PATTERN::RESERVED)}.json"
      )

      next unless mtc_file_exists?(target_coll_file, id) # If there's no file, ignore.

      parent_coll['child_collections'] << id # Add id to new, child_collections array.

      mtc_process_collection(mtc_load_file(target_coll_file), collections_dir)
    end

    # Remove collections from the member array.
    remove_from_members.each { |id| parent_coll['member_ids_ssim'].delete(id) }

    puts "\n\nFinished subcollections for #{parent_coll['id']}"
    puts "--------------"

    parent_coll
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
  # Runs the CollectionMigrator on the collection and rescues if LDP goes down.
  # @param {hash} coll
  #   The collection to be migrated.
  def mtc_log_and_migrate(coll)
    begin
      Tufts::CollectionMigrator.migrate(coll)
    rescue Ldp::Gone => e
      puts "LDP went down, waiting 15 seconds. (#{Time.new.inspect})"
      sleep(15)

      Tufts::CollectionMigrator.migrate(coll)
    end
  end
end
