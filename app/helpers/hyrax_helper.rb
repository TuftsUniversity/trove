require 'hyrax/name'

module HyraxHelper
  include ::BlacklightHelper
  include Hyrax::BlacklightOverride
  include Hyrax::HyraxHelperBehavior
  include CollectionTypeHelper
  include CollectionSidebarHelper
  include SortingHelper
end
