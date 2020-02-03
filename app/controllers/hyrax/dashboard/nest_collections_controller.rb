# Patching to use our NestCollectionForm instead of Hyrax's
require_dependency Hyrax::Engine.root.join('app', 'controllers', 'hyrax', 'dashboard', 'nest_collections_controller').to_s

module Hyrax
  module Dashboard
    class NestCollectionsController < ApplicationController
      self.form_class = Tufts::Forms::Dashboard::NestCollectionForm # Adding tufts form
    end
  end
end
