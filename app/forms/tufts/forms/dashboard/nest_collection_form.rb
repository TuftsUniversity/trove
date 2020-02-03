# Same as Hyrax::NestCollectionForm, but we remove subcollections from work orders when they're removed from parents

module Tufts
  module Forms
    module Dashboard
      # Responsible for validating that both the parent and child are valid for nesting; If so, then
      # also responsible for persisting those changes.
      class NestCollectionForm < Hyrax::Forms::Dashboard::NestCollectionForm
        def remove
          if context.can? :edit, parent
            persistence_service.remove_nested_relationship_for(parent: parent, child: child)
            remove_child_from_order(parent, child)
          else
            errors.add(:parent, :cannot_remove_relationship)
            false
          end
        end

        private

        ##
        # Remove child from parent's subcollection order
        # @param
        def remove_child_from_order(parent, child)
          order = parent.subcollection_order
          return if order.blank?
          parent.update_order(order - [child.id], :subcollection)
        end
      end
    end
  end
end
