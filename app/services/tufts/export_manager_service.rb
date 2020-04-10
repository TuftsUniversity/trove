##
# Saves, Deletes, and Retrieves PDFs and PPTs that are being exported.
module Tufts
  class ExportManagerService
    # Set paths in which to save the files - saving these on the class so exporters and
    #   controllers can access them and we don't have to reinitialize every export.
    class << self
      # Set in initializers/tufts_export.rb
      def export_base_path=(path)
        @export_base_path = path
      end

      def export_base_path
        @export_base_path
      rescue
        ''
      end

      def ppt_path
        "#{@export_base_path}/ppts"
      end

      def pdf_path
        "#{@export_base_path}/pdfs"
      end
    end

    # @param {Collection} collection
    #   The Collection that's being exported
    # @param {str} type
    #   The type of asset: pdf or ppt.
    def initialize(collection, type)
      # Set export_valid to false and quit if the type's no good.
      return unless(type_valid?(type))

      # Export is invalid if we can't initialize directories.
      @export_valid = initialize_directories
      return unless @export_valid

      case(type)
      when 'ppt'
        @target_path = ppt_path
        @exporter = PowerPointCollectionExporter.new(collection, @target_path)
        @file_name = @exporter.pptx_file_name
      when 'pdf'
        @target_path = pdf_path
        @exporter = PdfCollectionExporter.new(collection, @target_path)
        @file_name = @exporter.pdf_file_name
      end

      @full_path = "#{@target_path}/#{@file_name}"
    end

    # Retrieves asset if it exists, or creates it if it doesn't.
    def retrieve_asset
      return unless(@export_valid)

      if(asset_exists?)
        @full_path
      else
        @exporter.export
      end
    end

    def delete_asset
      File.unlink(@full_path) if(@export_valid)
    end

    def asset_exists?
      File.exists?(@full_path)
    end

    private

      def type_valid?(type)
        if(type == 'pdf' || type == 'ppt')
          true
        else
          Rails.logger.warn("#{type} is not a valid export type, use 'pdf' or 'ppt'.")
          @export_valid = false
          false
        end
      end

      # Sets up the pdf and ppt directories and the base directory, if necessary.
      def initialize_directories
        if(base_path.present?)
          [base_path, pdf_path, ppt_path].each { |path| Dir.mkdir(path) unless File.exist?(path) }
          true
        else
          Rails.logger.warn('Export directories not initialized in Tufts::ExportManagerService!')
          false
        end
      rescue
        Rails.logger.warn('Export directories not initialized in Tufts::ExportManagerService!')
        false
      end

      # Shortcuts
      def base_path
        self.class.export_base_path
      end
      def pdf_path
        self.class.pdf_path
      end
      def ppt_path
        self.class.ppt_path
      end
  end
end