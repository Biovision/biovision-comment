# frozen_string_literal: true

# Add column with approval flag to comments
class AddApprovedToComments < ActiveRecord::Migration[5.2]
  def up
    return if column_exists?(:comments, :approved)

    add_column :comments, :approved, :boolean, default: true, null: false
  end

  def down
    # No rollback needed
  end
end
