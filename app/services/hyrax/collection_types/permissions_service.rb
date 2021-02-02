require_dependency Hyrax::Engine.root.join('app', 'services', 'hyrax', 'collection_types', 'permissions_service').to_s

module Hyrax
  module CollectionTypes
    class PermissionsService
      # PATCH: Fixing Dangerous query method that will not be in Rails 6.0.
      # Fixed in Hyrax 3.0 - can be removed when upgrading to that.
      def self.collection_type_ids_for_user(roles:, user: nil, ability: nil)
        return false unless user.present? || ability.present?
        return Hyrax::CollectionType.all.select(:id).distinct.pluck(:id) if user_admin?(user, ability)
        Hyrax::CollectionTypeParticipant.where(agent_type: Hyrax::CollectionTypeParticipant::USER_TYPE,
                                               agent_id: user_id(user, ability),
                                               access: roles)
                                        .or(
                                          Hyrax::CollectionTypeParticipant.where(agent_type: Hyrax::CollectionTypeParticipant::GROUP_TYPE,
                                                                                 agent_id: user_groups(user, ability),
                                                                                 access: roles)
                                        )
                                        .select(:hyrax_collection_type_id)
                                        .distinct
                                        .pluck(:hyrax_collection_type_id)
      end

      # PATCH: Fixing Dangerous query method that will not be in Rails 6.0.
      # Fixed in Hyrax 3.0 - can be removed when upgrading to that.
      def self.agent_ids_for(collection_type:, agent_type:, access:)
        Hyrax::CollectionTypeParticipant.where(hyrax_collection_type_id: collection_type.id,
                                               agent_type: agent_type,
                                               access: access).pluck(Arel.sql('DISTINCT agent_id'))
      end
      private_class_method :agent_ids_for

      # PATCH: Fixing Dangerous query method that will not be in Rails 6.0.
      # Fixed in Hyrax 3.0 - can be removed when upgrading to that.
      def self.user_edit_grants_for_collection_of_type(collection_type: nil)
        return [] unless collection_type
        Hyrax::CollectionTypeParticipant.joins(:hyrax_collection_type).where(hyrax_collection_type_id: collection_type.id,
                                                                             agent_type: Hyrax::CollectionTypeParticipant::USER_TYPE,
                                                                             access: Hyrax::CollectionTypeParticipant::MANAGE_ACCESS).pluck(Arel.sql('DISTINCT agent_id'))
      end

      # PATCH: Fixing Dangerous query method that will not be in Rails 6.0.
      # Fixed in Hyrax 3.0 - can be removed when upgrading to that.
      def self.group_edit_grants_for_collection_of_type(collection_type: nil)
        return [] unless collection_type
        groups = Hyrax::CollectionTypeParticipant.joins(:hyrax_collection_type).where(hyrax_collection_type_id: collection_type.id,
                                                                                      agent_type: Hyrax::CollectionTypeParticipant::GROUP_TYPE,
                                                                                      access: Hyrax::CollectionTypeParticipant::MANAGE_ACCESS).pluck(Arel.sql('DISTINCT agent_id'))
        groups | ['admin']
      end
    end
  end
end
