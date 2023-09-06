source 'https://rubygems.org'
git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2'
# Use sqlite3 as the database for Active Record
gem 'mysql2'
gem 'sqlite3', '~> 1.3.6'
# Use Puma as the app server
gem 'puma', '~> 4.3'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  #gem 'spring'
  #gem 'spring-commands-rspec'
end

gem 'blacklight_range_limit', '~> 6.3', '>= 6.3.2'
gem 'bootstrap-sass', '~> 3.0'
gem 'devise'
gem 'devise-guests', '~> 0.6'
gem 'devise_ldap_authenticatable'
gem 'hydra-role-management'
gem 'hyrax', '2.9.3'
gem 'jquery-rails'
gem 'mimemagic', '0.3.10'
gem 'okcomputer'
gem 'pretender'
gem 'riiif', '~> 2.0'
gem 'rsolr', '>= 1.0', '< 3'
gem 'sidekiq', '~> 5.2'
gem 'simple_token_authentication', '~> 1.0'
gem 'tufts-curation', git: 'https://github.com/TuftsUniversity/tufts-curation', tag: 'v1.2.9'
gem 'twitter-typeahead-rails', '0.11.1.pre.corejavascript'

group :development, :test do
  gem 'solr_wrapper', '~> 2.1.0'
  gem 'fcrepo_wrapper'
  gem 'rspec-rails'
  gem 'simplecov'
  gem 'simplecov-lcov', '~> 0.8.0'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :test do
  gem 'factory_bot_rails'
  gem 'ffaker'
  gem 'ladle'
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'webdrivers', '~> 4.0', require: false
end
