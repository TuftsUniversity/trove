class CreateTuftsCollectionOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :tufts_collection_orders do |t|
      t.text :order
      t.string :collection_id, null: false
      t.integer :item_type, null: false, default: 0

      t.timestamps
    end
    # Only one order per type per collection.
    add_index :tufts_collection_orders, [:collection_id, :item_type], unique: true
  end
end
