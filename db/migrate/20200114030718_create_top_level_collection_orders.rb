class CreateTopLevelCollectionOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :top_level_collection_orders do |t|
      t.text :order
      t.string :user_id, null: false, unique: true

      t.timestamps
    end

    add_index :top_level_collection_orders, :user_id
  end
end
