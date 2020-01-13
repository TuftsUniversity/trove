class ChangeValueToBeMediumtextInContentBlocks < ActiveRecord::Migration[5.1]
  def up
    change_column :content_blocks, :value, :text, limit: 16.megabytes - 1
  end

  def down
    change_column :content_blocks, :value, :text, limit: 64.kilobytes - 1
  end
end
