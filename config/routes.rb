Rails.application.routes.draw do

  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new
  mount Riiif::Engine => 'images', as: :riiif if Hyrax.config.iiif_image_server?
  mount Blacklight::Engine => '/'

    concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
    concerns :range_searchable
  end

  if Rails.env.production? || Rails.env.stage?
    devise_for :users, controllers: { omniauth_callbacks: "omniauthcallbacks" }, skip: [:sessions]
    devise_scope :user do
      post 'sign_in', to: 'omniauth#new', as: :new_user_session
      post 'sign_in', to: 'omniauth_callbacks#shibboleth', as: :new_session
      get 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
    end
  else
    devise_for :users
  end
  
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
  get '/impersonate_user', to: 'impersonates#index'
  get '/impersonate/:id', to: 'impersonates#impersonate', constraints: { id: /.*/ }, as: :impersonate
  get '/stop_impersonating', to: 'impersonates#stop_impersonating', as: :stop_impersonating

  # Adding copy method to collections
  scope module: 'hyrax' do
    get '/collections/copy/:id', controller: 'collections', action: :copy
    get '/collections/dl_powerpoint/:id', controller: 'collections', action: :dl_powerpoint, :defaults => { :format => 'pptx' }
    get '/collections/dl_pdf/:id', controller: 'collections', action: :dl_pdf, :defaults => { :format => 'pdf' }

    namespace :dashboard do
      get '/collections/copy/:id', controller: 'collections', action: :copy
      get '/collections/upgrade/:id', controller: 'collections', action: :upgrade
      get '/collections/dl_powerpoint/:id', controller: 'collections', action: :dl_powerpoint, :defaults => { :format => 'pptx' }
      get '/collections/dl_pdf/:id', controller: 'collections', action: :dl_pdf, :defaults => { :format => 'pdf' }
      post '/collections/update_work_order/:id/:page/:per_page', controller: 'collections', action: :update_work_order
      post '/collections/update_subcollection_order/:id', controller: 'collections', action: :update_subcollection_order
    end
  end

  post '/update_top_level_course_collection', controller: 'top_level_collection_orders', action: :set_course_order
  post '/update_top_level_personal_collection/:id', controller: 'top_level_collection_orders', action: :set_personal_order

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
