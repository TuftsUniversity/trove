class Ability
  include Hydra::Ability

  include Hyrax::Ability
  self.ability_logic += [:everyone_can_create_curation_concerns, :trove_admin_permissions] 
  self.ability_logic -= [:admin_permissions]
  # Add this to your ability_logic if you want all logged in users to be able
  # to submit content
  def everyone_can_create_curation_concerns
    return unless registered_user?
    can :create, [Collection]
  end
  
  # Define any customized permissions here.
  def custom_permissions
    # Limits deleting objects to a the admin user
    #
    # if current_user.admin?
    #   can [:destroy], ActiveFedora::Base
    # end

    # Limits creating new objects to a specific group
    #
    # if user_groups.include? 'special_group'
    #   can [:create], ActiveFedora::Base
    # end
    can [:advanced], Image
    can [:dl_powerpoint], Collection
    can [:dl_pdf], Collection
    
  end
  def trove_admin_permissions
    return unless admin?
    # TODO: deprecate this. We no longer have a dashboard just for admins
    can :read, :admin_dashboard
    alias_action :edit, to: :update
    alias_action :show, to: :read
    alias_action :discover, to: :read
    can :update, :appearance
    can :manage, String # The identifier of a work or FileSet
    can :manage, curation_concerns_models
    
    can :manage, :collection_types
  end

end
