# frozen_string_literal: true
yaml_config = YAML.safe_load(
  File.read(Rails.root.join('config', 'tufts_export.yml'))
)[Rails.env]

Tufts::ExportManagerService.set_export_base_path(yaml_config['export_path'])
