namespace :tufts do
  desc 'Creates all the users we need for the Trove migration'
  task migrate_trove_users: :environment do
    users_file = 'tmp/trove_usernames.txt'

    puts "\nStarting User Migration"

    usernames = File.open(users_file).read
    usernames.each_line do |name|
      name.gsub!("\n", '')

      if(User.where(username: name).count > 0)
        puts "\n#{name} already exists. Skipping."
        next
      end

      puts "\nCreating #{name}"

      user = User.find_or_create_by!(
        username: name,
        email: "#{name}@tufts.edu",
        display_name: name
      ) do |u|
        u.password = SecureRandom.base64(24)
      end
    end
  end
end

