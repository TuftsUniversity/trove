##
# Saves, Deletes, and Retrieves PDFs and PPTs that are being exported.
module Tufts
  class ExportManagerService
    # Set paths in which to save the files - saving these on the class so exporters and
    #   controllers can access them and we don't have to reinitialize every export.
    class_attribute :export_base_path

    # @param {Collection} collection
    #   The Collection that's being exported
    # @param {str} type
    #   The type of asset: pdf or pptx.
    def initialize(collection, type)
      @export_valid = false

      return unless(type_valid?(type))
      return unless initialize_directories

      case(type)
      when 'pptx'
        @target_path = pptx_path
        @exporter = PowerPointCollectionExporter.new(collection, @target_path)
        @file_name = @exporter.pptx_file_name
      when 'pdf'
        @target_path = pdf_path
        @exporter = PdfCollectionExporter.new(collection, @target_path)
        @file_name = @exporter.pdf_file_name
      end

      @full_path = "#{@target_path}/#{@file_name}"

      @readable_filename =
        Array(collection.title).first.underscore.gsub(' ', '_').gsub("'", '_') + '.' + type

      @export_valid = true
    end

    # Retrieves asset if it exists, or creates it if it doesn't.
    def retrieve_asset
      return unless(@export_valid)

      if(asset_exists?)
        Rails.logger.info("\n\n\nAsset exists, retrieving #{@full_path}.\n\n\n")
        @full_path
      else
        Rails.logger.info("\n\n\nAsset doesn't exist, creating #{@full_path}.\n\n\n")
        @exporter.export
      end
    end

    def delete_asset
      File.unlink(@full_path) if(@export_valid)
    end

    # Shortcut to make deleting all assets easily
    def self.delete_all_assets(collection)
      self.new(collection, 'pptx').delete_asset
      self.new(collection, 'pdf').delete_asset
    end

    def asset_exists?
      File.exists?(@full_path)
    end

    # For use in the controller, generating easier-to-read filenames.
    def readable_filename
      @readable_filename
    end

    private

      def type_valid?(type)
        if(type == 'pdf' || type == 'pptx')
          true
        else
          Rails.logger.warn("#{type} is not a valid export type, use 'pdf' or 'pptx'.")
          false
        end
      end

      # Sets up the pdf and pptx directories and the base directory, if necessary.
      def initialize_directories
        if(base_path.present?)
          [base_path, pdf_path, pptx_path].each { |path| Dir.mkdir(path) unless File.exist?(path) }
          true
        else
          Rails.logger.warn('Export directories not initialized in Tufts::ExportManagerService!')
          false
        end
      rescue
        Rails.logger.warn('Export directories not initialized in Tufts::ExportManagerService!')
        false
      end

      def base_path
        if(self.class.export_base_path.blank?)
          Rails.logger.info("\n\n#{self.class}.export_base_path not set! Setting now.\n\n")
          load_base_path_from_config
        end

        self.class.export_base_path
      end

      def pdf_path
        base_path + '/pdfs'
      end
      def pptx_path
        base_path + '/ppts'
      end

      # Save the export path on the class, so we don't have to keep reloading it.
      def load_base_path_from_config(config = 'tufts_export.yml')
        yaml_config =
          YAML.safe_load(
            File.read(
              Rails.root.join('config', config)
            )
          )[Rails.env]

        Tufts::ExportManagerService.export_base_path = yaml_config['export_path']
      end
  end
end