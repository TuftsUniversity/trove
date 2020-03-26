require 'rails_helper'

describe PdfCollectionExporter do
  # This lets us set the export_dir, by setting what `now` will be.
  before do
    xmas = Time.new(2012, 12, 25, 5, 15, 45, '+00:00')
    allow(Time).to receive(:now) { xmas }
  end

  let(:collection) { build(:course_collection) }
  let(:exporter) { PdfCollectionExporter.new(collection) }

  it 'has a name for the export file', :exporter => 'true'  do
    collection.title = ['Student Research in the 1960s']
    expect(exporter.pdf_file_name).to eq 'student_research_in_the_1960s.pdf'
  end

  context 'when generating the file' do
    before { collection.update(title: ['Student Research in the 1960s']) }
    after { FileUtils.rm_rf(exporter.pptx_exporter.export_dir, secure: true) }

    it 'generates the file and returns the file path', :exporter => 'true' do
      export_file_path = exporter.export

      expect(export_file_path.match(/student_research_in_the_1960s.*.pdf/)).to_not be_nil
      expect(File.exist?(export_file_path)).to eq true
    end
  end
end
