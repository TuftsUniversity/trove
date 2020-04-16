require 'rails_helper'

describe PdfCollectionExporter do
  include FileManager

  before(:all) { Tufts::ExportManagerService.export_base_path = Rails.root.join('tmp', 'exports').to_s }

  let(:target_dir) { Tufts::ExportManagerService.export_base_path + '/pdfs' }
  let(:collection) { build_stubbed(:course_collection) }
  let(:exporter) { PdfCollectionExporter.new(collection, target_dir) }
  let(:pptx_file) { "#{target_dir}/#{collection.id}.pptx" }

  it 'has a name for the export file', :exporter => 'true'  do
    expect(exporter.pdf_file_name).to eq("#{collection.id}.pdf")
  end

  context '#export' do
    before(:all) { create_export_dirs }
    after(:all) { destroy_export_dirs }

    # Ideally you don't test 3 things at once, but I don't want to run this 3 times.
    it 'generates the file, returns the file path, deletes the leftover pptx file', :exporter => 'true' do
      export_file_path = exporter.export
      expect(export_file_path).to eq("#{target_dir}/#{exporter.pdf_file_name}")
      expect(File.exist?(export_file_path)).to eq(true)
      expect(File.exist?(pptx_file)).to eq(false)
    end
  end
end
