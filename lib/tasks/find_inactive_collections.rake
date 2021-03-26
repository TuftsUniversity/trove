# TODO
# This should probably all be a service at this point. It got more complicated than anticipated.
namespace :tufts do
  desc 'Finds and logs collections owned by users no longer affiliated with Tufts'
  task find_inactive_collections: :environment do
    include CollectionTypeHelper
    Devise.ldap_use_admin_to_bind = true # For certain LDAP params, we need to be admin
    lp = fic_ldap_params

    inactive_users = {}
    active_users = {}

    fic_all_users.each do |u|
      stats = {
        name: Devise::LDAP::Adapter.get_ldap_param(u, lp['name']),
        mail: Devise::LDAP::Adapter.get_ldap_param(u, lp['email']),
        eligibility: Devise::LDAP::Adapter.get_ldap_param(u, lp['active'])
      }

      # Remove all the annoying arrays
      stats.each { |k,v| stats[k] = v.first unless v.nil? }

      if(fic_expired_user?(stats, lp['active']))
        stats[:collections] = fic_collection_details(u)
        inactive_users[u] = stats
      else
        active_users[u] = stats
      end
    end

    File.open('inactive_collections.json', 'w') { |f| f.write JSON.pretty_generate(inactive_users) }
    File.open('active_collections.json', 'w') { |f| f.write JSON.pretty_generate(active_users) }
  end

  desc 'Deletes users no longer affiliated with Tufts, and their collections'
  task destroy_inactive_collections: :environment do
    include CollectionTypeHelper
    Devise.ldap_use_admin_to_bind = true # For certain LDAP params, we need to be admin
    lp = fic_ldap_params

    unless(lp['active'].nil?)
      fic_all_users.each do |u|
        next unless fic_expired_user?(u, lp['active'])

        puts "Deleting #{u}, (mail: #{Devise::LDAP::Adapter.get_ldap_param(u, lp['email'])}), and their Collections"
        fic_delete_collections(u)

        begin
          u.destroy
        rescue => error
          puts "#{u} has no User object?"
          puts error.message
        end
      end
    end
  end

  ##
  # Gets all the users in the db without instantiating an object for every user.
  def fic_all_users
    User.connection.select_values(User.select('username').to_sql)
  end

  ##
  # Determines if user is current student or employee of Tufts.
  #
  # @param {str|hash} user
  #   The username of the user, or a hash including the user's eligibility. 
  def fic_expired_user?(user, ldap_active_param)
    begin
      if(user.is_a?(Hash) && user.key?(:eligibility))
        lgbty = user[:eligibility]
      elsif(user.is_a?(String))
        lgbty = Devise::LDAP::Adapter.get_ldap_param(user, ldap_active_param)
      else
        puts "#{user} needs inspection. Preserving user and collections for now."
        return true
      end

      return ['former_student', 'former_employee', 'ineligible'].include?(lgbty)
    rescue => error
      puts "#{user} needs inspection. Preserving user and collections for now."
      puts error.message
      return true
    end
  end

  ##
  # Returns all the PersonalCollections of a specific user.
  #
  # @param {str} depositor
  #   The username of the user.
  def fic_get_collections(depositor)
    Collection.where(displays_in_tesim: ['trove'], collection_type_gid_ssim: [personal_gid], depositor: [depositor])
  end
 
  ##
  # Builds a hash of information about collections of a specific user.
  #
  # @param {str} depositor
  #   The username of the user.
  def fic_collection_details(depositor)
    colls = fic_get_collections(depositor)
    return {} if colls.count == 0

    coll_info = {}
    colls.each do |c|
      coll_info[c.id] = {
        title: c.title.first,
        type: c.collection_type.title
      }

      coll_info[c.id][:works] = c.member_work_ids unless c.member_work_ids.empty?
      coll_info[c.id][:work_order] = c.work_order unless c.work_order.empty?
      coll_info[c.id][:subcollections] = c.member_collection_ids unless c.member_collection_ids.empty?
      coll_info[c.id][:subcollection_order] = c.subcollection_order unless c.subcollection_order.empty?
    end

    coll_info
  end

  ##
  # Destroys the Collections of a specific user.
  # CollectionOrders are deleted by default when their parent Collections are deleted.
  #
  # @param {str} depositor
  #   The username of the user. 
  def fic_delete_collections(depositor)
    fic_get_collections(depositor).destroy_all
  end

  ##
  # Retrieves the LDAP parameter names from a config file, to keep them secure.
  #
  # @return {hash}
  #   {'name' => '', 'email' => '', 'active' => ''}
  def fic_ldap_params
    YAML.safe_load(
      File.read(
        Rails.root.join('config', 'tufts.yml')
      )
    )[Rails.env]['ldap']
  end
end
