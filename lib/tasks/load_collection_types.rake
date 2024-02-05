namespace :db do
    desc "Load data into the hyrax_collection_types table"
    task load_hyrax_data: :environment do
      data = [
        [1,'User Collection','A User Collection can be created by any user to organize their works.','user_collection',1,1,1,1,0,0,0,0,1,'#705070'],
        [2,'Admin Set','An aggregation of works that is intended to help with administrative control. Admin Sets provide a way of defining behaviors and policies around a set of works.','admin_set',0,0,1,0,1,1,1,1,0,'#405060'],
        [3,'Course Collection','For Trove','course_collection',1,1,1,1,0,0,0,1,1,'#663333'],
        [4,'Personal Collection','For Trove','personal_collection',1,1,1,1,0,0,0,1,1,'#663333']
      ]

      data.each do |row|
        # Assuming you have a model named HyraxCollectionType corresponding to the table
        Hyrax::CollectionType.create(
          id: row[0],
          title: row[1],
          description: row[2],
          machine_id: row[3],
          nestable: row[4],
          discoverable: row[5],
          sharable: row[6],
          allow_multiple_membership: row[7],
          require_membership: row[8],
          assigns_workflow: row[9],
          assigns_visibility: row[10],
          share_applies_to_new_works: row[11],
          brandable: row[12],
          badge_color: row[13]
        )
      end

      puts "Data loaded into hyrax_collection_types table"
    end
  end
