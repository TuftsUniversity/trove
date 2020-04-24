require 'rails_helper'

describe Tufts::ExportManagerService do
  include FileManager

  before(:all) do
    # Need to unset this in one test, but then set it back for the rest. Can't access let() vars in before(:all).
    @target_path = Rails.root.join('tmp', 'exports').to_s
    Tufts::ExportManagerService.export_base_path = @target_path
  end

  let(:collection) { build_stubbed(:course_collection) }
  let(:ppt_manager) { Tufts::ExportManagerService.new(collection, 'pptx') }

  after(:each) { destroy_export_dirs }

  it 'is invalid if the directories cant be created' do
    Tufts::ExportManagerService.export_base_path = '/'
    expect(ppt_manager.instance_variable_get(:@export_valid)).to be false

    Tufts::ExportManagerService.export_base_path = @target_path
  end

  it 'is invalid with an invalid type' do
    expect(Tufts::ExportManagerService.new(collection, 'bad_type')
        .instance_variable_get(:@export_valid)).to be false
  end

  it 'creates the test directories if they dont already exist' do
    base_path = Tufts::ExportManagerService.export_base_path
    pdf_path = base_path + '/pdfs'
    pptx_path = base_path + '/ppts'

    expect(base_path).not_to exist_on_filesystem
    ppt_manager
    expect(pdf_path).to exist_on_filesystem
    expect(pptx_path).to exist_on_filesystem
  end

  describe '#retrieve_asset' do
    it 'generates the file if it doesnt already exist' do
      ppt_manager
      full_path = ppt_manager.instance_variable_get(:@full_path)

      expect(full_path).not_to exist_on_filesystem
      ppt_manager.retrieve_asset
      expect(full_path).to exist_on_filesystem
    end

    it 'doesnt generate a file if it already exists' do
      ppt_files = ppt_manager.export_base_path + '/ppts/*'

      expect(Dir[ppt_files].count).to be 0
      ppt_manager.retrieve_asset
      ppt_manager.retrieve_asset
      expect(Dir[ppt_files].count).to be 1
    end
  end

  describe '#delete_asset' do
    it 'deletes the file' do
      ppt_manager
      full_path = ppt_manager.instance_variable_get(:@full_path)

      ppt_manager.retrieve_asset
      expect(full_path).to exist_on_filesystem
      ppt_manager.delete_asset
      expect(full_path).not_to exist_on_filesystem
    end
  end

  describe '#asset_exists?' do
    it 'returns true if asset exists' do
      ppt_manager.retrieve_asset
      expect(ppt_manager.asset_exists?).to be true
    end

    it 'returns false if asset doesnt exist' do
      expect(ppt_manager.asset_exists?).to be false
    end
  end

  describe '#readable_filename' do
    it 'returns the collection title to use as a filename' do
      collection.title = ['Test Collection Title']
      expect(ppt_manager.readable_filename).to eq('test_collection_title.pptx')
    end
  end

  describe '#self.delete_all_assets', slow: true do
    it 'deletes both pdf and ppt files for collection' do
      pdf_manager = Tufts::ExportManagerService.new(collection, 'pdf')
      pdf_file = pdf_manager.instance_variable_get(:@full_path)
      pdf_manager.retrieve_asset

      ppt_file = ppt_manager.instance_variable_get(:@full_path)
      ppt_manager.retrieve_asset


      expect(pdf_file).to exist_on_filesystem
      expect(ppt_file).to exist_on_filesystem

      Tufts::ExportManagerService.delete_all_assets(collection)

      expect(pdf_file).not_to exist_on_filesystem
      expect(ppt_file).not_to exist_on_filesystem
    end
  end
end