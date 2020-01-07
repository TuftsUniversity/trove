require_dependency Hyrax::Engine.root.join('app', 'controllers', 'hyrax', 'collections_controller').to_s


module Hyrax
  class CollectionsController < ApplicationController
    include TuftsCollectionControllerBehavior
  end
end
