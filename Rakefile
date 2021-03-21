# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

require 'solr_wrapper/rake_task' unless Rails.env.production?
require 'byebug'
require 'fileutils'

desc "cache_images_for_ppt_export"
task cache_images_for_ppt_export: :environment do
  puts "Loading File"
  logger = Logger.new('log/ppt_cache.log')
  CSV.foreach("/usr/local/hydra/trove/images_to_cache.txt", headers: false, header_converters: :symbol, encoding: "ISO8859-1:utf-8") do |row|
    found = false
    pid = row[0]
    begin
      member_image = ActiveFedora::Base.find(pid)
      file_set = member_image.file_sets[0]
      url = Riiif::Engine.routes.url_helpers.image_url(file_set.files.first.id, host: Rails.configuration.host, port: Rails.configuration.port, protocol: Rails.configuration.protocol, size: "2000,")
      params = { :user_username => Rails.application.secrets.riiif_user, :user_token => Rails.application.secrets.riiif_token }
      uri = URI.parse(url)
      uri.query = URI.encode_www_form( params )
      uri_s = uri.to_s
      base_name = File.basename(uri.path)
      temp_file = Rails.root.join('tmp', 'images', pid).to_s

      logger.info "Processing  #{pid}"
      unless File.file?(temp_file)
        File.open(temp_file, "wb") do |file|
          file.write uri.open.read
        end
      end
    rescue ActiveFedora::RecordInvalid
      logger.error "ERROR invalid record #{pid}"
    rescue ActiveFedora::ObjectNotFoundError
      logger.error "ERROR not found #{pid}"
    end
  end
end
