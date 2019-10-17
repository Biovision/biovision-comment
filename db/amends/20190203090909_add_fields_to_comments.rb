# frozen_string_literal: true

# Adding "spam" flag and anonymous contact fields to comment
class AddFieldsToComments < ActiveRecord::Migration[5.2]
  def up
    add_column(:comments, :spam, :boolean, default: false, null: false) unless column_exists?(:comments, :spam)
    add_column(:comments, :author_name, :string) unless column_exists?(:comments, :author_name)
    add_column(:comments, :author_email, :string) unless column_exists?(:comments, :author_email)
  end

  def down
    # No rollback needed
  end
end
