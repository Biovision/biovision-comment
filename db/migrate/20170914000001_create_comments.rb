class CreateComments < ActiveRecord::Migration[5.0]
  def up
    unless Comment.table_exists?
      create_table :comments do |t|
        t.timestamps
        t.integer :parent_id
        t.references :user, foreign_key: true, on_update: :cascade, on_delete: :cascade
        t.references :agent, foreign_key: true, on_update: :cascade, on_delete: :nullify
        t.inet :ip
        t.boolean :visible, default: true, null: false
        t.boolean :locked, default: false, null: false
        t.boolean :deleted, default: false, null: false
        t.integer :upvote_count, default: 0, null: false
        t.integer :downvote_count, default: 0, null: false
        t.integer :vote_result, default: 0, null: false
        t.integer :commentable_id, null: false
        t.string :commentable_type, null: false
        t.text :body, null: false
      end

      add_index :comments, [:commentable_id, :commentable_type]
      add_foreign_key :comments, :comments, column: :parent_id, on_update: :cascade, on_delete: :cascade
    end
  end

  def down
    if Comment.table_exists?
      drop_table :comments
    end
  end
end
