##
# Saves, Deletes, and Retrives PDFs and PPTs that are being exported.
module Tufts
  class ExportManagerService

    # I know class vars are generally looked down on, but this is a basic use case where it's exactly what I need.
    class_attribute :export_base_path
    def self.set_export_base_path(path)
      @@export_base_path = path
    end

    private

    def export_base_path
      @@export_base_path
    rescue
      ''
    end
  end
end
