class CreateTuftsCollectionOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :tufts_collection_orders do |t|
      t.text :work_order
      t.string :collection_id, null: false

      t.timestamps
    end
    add_index :tufts_collection_orders, :collection_id, unique: true
  end
end
