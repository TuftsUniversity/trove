require 'fileutils'

module FileManager
  def create_export_dirs
    FileUtils.mkdir_p(Tufts::ExportManagerService.export_base_path + '/pdfs')
    FileUtils.mkdir_p(Tufts::ExportManagerService.export_base_path + '/ppts')
  end

  def destroy_export_dirs
    yaml_config =
    YAML.safe_load(
      File.read(
        Rails.root.join('config', 'tufts.yml')
      )
    )[Rails.env]


    FileUtils.rm_r(yaml_config['export_path']) if File.exists?(yaml_config['export_path'])
  end
end
