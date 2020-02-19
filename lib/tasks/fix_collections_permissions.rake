
namespace :tufts do
  desc 'Adds default permissions to collections without permissions'
  task fix_collection_perms: :environment do
    collections = Collection.where(displays_in: 'trove')
    
    puts "\nDeleting all permissions!\n"
    Hyrax::PermissionTemplate.destroy_all
    
    collections.each do |c|
      title = c.title.first
      begin
        person = User.where(username: c.depositor).first!
      rescue
        puts "\n#{title} has no depositor! \n"
        next
      end
      
      puts "\nAdding permissions for #{title} to #{person}! \n"
      Hyrax::Collections::PermissionsCreateService.create_default(collection: c, creating_user: person)
    end

    puts "\nUpdated the index. This may take a while\n"
    collections.each(&:update_index)
  end
end
