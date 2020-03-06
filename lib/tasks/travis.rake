# frozen_string_literal: true

unless Rails.env.production?
  APP_ROOT = File.dirname(__FILE__)
  require "solr_wrapper"
  require "fcrepo_wrapper"
  require 'solr_wrapper/rake_task'

  desc "Run Continuous Integration"
  task :travis do
    ENV["environment"] = "test"
    solr_params = {
      port: 8985,
      verbose: true,
      managed: true,
      version: '6.6.1'
    }
    fcrepo_params = {
      port: 8986,
      verbose: true,
      managed: true,
      enable_jms: false,
      fcrepo_home_dir: 'tmp/fcrepo4-test-data'
    }
    SolrWrapper.wrap(solr_params) do |solr|
      solr.with_collection(
        name: "hydra-test",
        persist: false,
        dir: Rails.root.join("solr", "conf")
      ) do
        FcrepoWrapper.wrap(fcrepo_params) do
          Rake::Task["hyrax:default_admin_set:create"].invoke
          # Rake::Task["tufts:fixtures:refresh"].invoke
          Rake::Task["spec"].invoke
        end
      end
    end
  end
end
