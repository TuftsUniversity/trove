require 'rails_helper'

describe PowerPointCollectionExporter do
  include FileManager

  before(:all) { Tufts::ExportManagerService.export_base_path = Rails.root.join('tmp', 'exports') }

  let(:target_dir) { Tufts::ExportManagerService.ppt_path }
  let(:collection) { build_stubbed(:course_collection) }
  let(:exporter) { PowerPointCollectionExporter.new(collection, target_dir) }

  it 'has a name for the export file', :exporter => 'true' do
    expect(exporter.pptx_file_name).to eq("#{collection.id}.pptx")
  end

  describe "#export" do
    before(:all) { create_export_dirs }
    after(:all) { destroy_export_dirs }

    it 'generates the file and returns the file path', :exporter => 'true' do
      export_file_path = exporter.export
      expect(export_file_path).to eq("#{target_dir}/#{exporter.pptx_file_name}")
      expect(File).to exist(export_file_path)
    end
  end
end
