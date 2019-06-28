# frozen_string_literal: true

# Add data column to comments
class AddDataToComments < ActiveRecord::Migration[5.2]
  def up
    return if column_exists? :comments, :data

    add_column :comments, :data, :jsonb, default: {}, null: false
    add_index :comments, :data, using: :gin
  end

  def down
    # No rollback needed
  end
end
