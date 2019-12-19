Rails.application.routes.draw do

  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new
  mount Riiif::Engine => 'images', as: :riiif if Hyrax.config.iiif_image_server?
  mount Blacklight::Engine => '/'

    concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
    concerns :range_searchable

  end

  devise_for :users
  mount Hydra::RoleManagement::Engine => '/'

  mount Qa::Engine => '/authorities'
  mount Hyrax::Engine, at: '/'
  resources :welcome, only: 'index'
  root 'hyrax/homepage#index'
  curation_concerns_basic_routes
  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  get '/imageviewer/:id', to: 'hyrax/images#advanced', constraints: { id: /.*/ }, as: 'imageviewer'

  # Adding copy method to collections
  scope module: 'hyrax' do
    get '/collections/copy/:id', controller: 'collections', action: :copy

    namespace :dashboard do
      get '/collections/copy/:id', controller: 'collections', action: :copy
      get '/collections/upgrade/:id', controller: 'collections', action: :upgrade
      get '/collections/downgrade/:id', controller: 'collections', action: :downgrade
      get '/collections/dl_powerpoint/:id', controller: 'collections', action: :dl_powerpoint, :defaults => { :format => 'pptx' }
      get '/collections/dl_pdf/:id', controller: 'collections', action: :dl_pdf, :defaults => { :format => 'pdf' }
      get '/collections/update_work_order/:id', controller: 'collections', action: :update_work_order
    end
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
