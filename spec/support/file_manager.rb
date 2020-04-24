require 'fileutils'

module FileManager
  def create_export_dirs
    FileUtils.mkdir_p(Tufts::ExportManagerService.export_base_path + '/pdfs')
    FileUtils.mkdir_p(Tufts::ExportManagerService.export_base_path + '/ppts')
  end

  def destroy_export_dirs
    FileUtils.rm_r(Tufts::ExportManagerService.export_base_path) if
      File.exists?(Tufts::ExportManagerService.export_base_path)
  end
end
