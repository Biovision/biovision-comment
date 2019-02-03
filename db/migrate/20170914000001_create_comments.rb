# frozen_string_literal: true

# Migration for comments table
class CreateComments < ActiveRecord::Migration[5.0]
  def up
    return if Comment.table_exists?

    create_table :comments do |t|
      t.timestamps
      t.integer :parent_id
      t.references :user, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.references :agent, foreign_key: { on_update: :cascade, on_delete: :nullify }
      t.inet :ip
      t.boolean :visible, default: true, null: false
      t.boolean :locked, default: false, null: false
      t.boolean :deleted, default: false, null: false
      t.boolean :spam, default: false, null: false
      t.integer :upvote_count, default: 0, null: false
      t.integer :downvote_count, default: 0, null: false
      t.integer :vote_result, default: 0, null: false
      t.integer :commentable_id, null: false
      t.string :commentable_type, null: false
      t.string :author_name
      t.string :author_email
      t.text :body, null: false
    end

    add_index :comments, [:commentable_id, :commentable_type]
    add_foreign_key :comments, :comments, column: :parent_id, on_update: :cascade, on_delete: :cascade
  end

  def down
    drop_table :comments if Comment.table_exists?
  end
end
