require 'rails_helper'

describe PowerPointCollectionExporter do
  # This lets us set the export_dir, by setting what `now` will be.
  before do
    xmas = Time.new(2012, 12, 25, 5, 15, 45, '+00:00')
    allow(Time).to receive(:now) { xmas }
  end

  let(:collection) { build(:course_collection) }
  let(:exporter) { PowerPointCollectionExporter.new(collection) }

  it 'makes the export dir if it doesnt exist', :exporter => 'true' do
    export_dir = File.join(PowerPointCollectionExporter::PPTX_DIR, '2012_12_25_051545')

    FileUtils.rm_rf(export_dir, secure: true)
    exporter.export_dir
    expect(File).to exist(export_dir)
    FileUtils.rm_rf(export_dir, secure: true)
  end

  it 'has a name for the export file', :exporter => 'true' do
    collection.title = ['Student Research in the 1960s']
    expect(exporter.pptx_file_name).to eq('student_research_in_the_1960s.pptx')
  end

  describe "#export" do
    before { collection.update(title: ['Student Research in the 1960s']) }
    after { FileUtils.rm_rf(exporter.export_dir, secure: true) }

    it 'generates the file and returns the file path', :exporter => 'true' do
      export_file_path = exporter.export

      expect(export_file_path.match(/student_research_in_the_1960s.*.pptx/)).to_not be_nil
      expect(File).to exist(export_file_path)
    end
  end
end
