# Same as Hyrax::NestCollectionForm, but we remove subcollections from work orders when they're removed from parents

module Tufts
  module Forms
    module Dashboard
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
          # @param {Collection} parent
          #   The parent collection which owns the subcollection order that we're altering
          # @param {Collection} child
          #   The child collection whose id will be removed from the parent's order
          def remove_child_from_order(parent, child)
            order = parent.subcollection_order
            return if order.blank?
            parent.update_order(order - [child.id], :subcollection)
          end
      end
    end
  end
end
