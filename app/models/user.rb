class User < ApplicationRecord
  acts_as_token_authenticatable
  # Connects this user object to Hydra behaviors.
  include Hydra::User
  # Connects this user object to Role-management behaviors.
  include Hydra::RoleManagement::UserRoles


  # Connects this user object to Hyrax behaviors.
  include Hyrax::User
  include Hyrax::UserUsageStats



  if Blacklight::Utils.needs_attr_accessible?
    attr_accessible :email, :password, :password_confirmation
  end
  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  if Rails.env.development? || Rails.env.test?
    devise :ldap_authenticatable, :rememberable, :validatable
  else
    devise_modules = [:omniauthable, :rememberable, :trackable, omniauth_providers: [:shibboleth]]
    ##devise_modules.prepend(:database_authenticatable) if AuthConfig.use_database_auth?
    devise(*devise_modules)
  end

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    display_name || user_key
  end

  def add_role(name)
    role = Role.find_by(name: name)
    role = Role.create(name: name) if role.nil?
    role.users << self
    role.save
    reload
  end

  def remove_role(name)
    role = Role.find_by(name: name)
    role.users.delete(self) if role && role.users && role.users.include?(self)
    reload
  end

  # Hyrax 2.0 expects this to be set for the user
  def preferred_locale
    'en'
  end

  def ldap_before_save
    self.email = Devise::LDAP::Adapter.get_ldap_param(username, "mail").first
    self.display_name = Devise::LDAP::Adapter.get_ldap_param(username, "tuftsEduDisplayNameLF").first
  end

  # allow omniauth (including shibboleth) logins
  #   this will create a local user based on an omniauth/shib login
  #   if they haven't logged in before
  def self.from_omniauth(auth)
    Rails.logger.warn "auth = #{auth.inspect}"
    # Uncomment the debugger above to capture what a shib auth object looks like for testing
    user = where(username: auth[:uid]).first_or_create
    user.display_name = auth[:name]
    user.username = auth[:uid]
    user.email = auth[:mail]
    user.save
    user
  end
end


# Override a Hyrax class that expects to create system users with passwords
module Hyrax::User
  module ClassMethods
    def find_or_create_system_user(user_key)
      u = ::User.find_or_create_by(username: user_key)
      u.display_name = user_key
      u.email = "#{user_key}@example.com"
      u.password = ('a'..'z').to_a.shuffle(random: Random.new).join
      u.save
      u
    end
  end
end
