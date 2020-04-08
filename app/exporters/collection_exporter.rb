class CollectionExporter
  def initialize(collection, export_dir)
    @collection = collection
    @export_dir = export_dir
  end

  def export_base_file_name
    @collection.id
  end
end
