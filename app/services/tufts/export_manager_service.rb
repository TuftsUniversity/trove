##
# Saves, Deletes, and Retrives PDFs and PPTs that are being exported.
module Tufts
  class ExportManagerService
    # Set paths in which to save the files - saving these on the class so the exporter can get them and we don't have
    #   to reinitialize every export.
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
      @paths_working = initialize_directories

      if(@paths_working)
        @collection = collection
        @type = type
      else
        Rails.logger.warn('Export directories not initialized in Tufts::ExportManagerService!')
      end
    end

    # Sets up the pdf and ppt directories and the base directory, if necessary.
    def initialize_directories
      if(base_path.present?)
        [base_path, pdf_path, ppt_path].each { |path| Dir.mkdir(path) unless File.exist?(path) }
        true
      else
        false
      end
    rescue
      false
    end

    # Creates and saves the asset.
    def create_asset
      return unless(@paths_working)
    end

    # Deletes the asset.
    def delete_asset
      return unless(@paths_working)
    end

    # Retrieves asset if it exists. Returns nil if it's not there.
    def retrieve_asset
      return unless(@paths_working)
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
