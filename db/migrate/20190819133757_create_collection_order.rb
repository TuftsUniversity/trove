class CreateCollectionOrder < ActiveRecord::Migration[5.1]
  def change
    create_table :collection_orders, id: false do |t|
      t.string :collection_id, primary_key: true
      t.json :work_order
    end
  end
end
