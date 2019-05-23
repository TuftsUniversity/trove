# Override Hyrax::Forms::CollectionForm so we can add description as primary and have
# no secondary fields.
module Hyrax
  class CollectionForm < Hyrax::Forms::CollectionForm
    # Terms that appear above the accordion
    def primary_terms
      [:title, :description]
    end

    # We don't need any secondary terms for Trove
    def secondary_terms
      []
    end
  end
end
