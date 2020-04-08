require 'fileutils'

module FileManager
  def create_export_dirs
    FileUtils.mkdir_p(Tufts::ExportManagerService.pdf_path)
    FileUtils.mkdir_p(Tufts::ExportManagerService.ppt_path)
  end

  def destroy_export_dirs
    FileUtils.rm_r(Tufts::ExportManagerService.export_base_path)
  end
end
