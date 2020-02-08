# frozen_string_literal: true

# Migration for comments table
class CreateComments < ActiveRecord::Migration[5.0]
  def up
    create_component_record
    create_comments_table unless Comment.table_exists?
  end

  def down
    drop_table :comments if Comment.table_exists?
  end

  private

  def create_comments_table
    create_table :comments, comment: 'Comment for commentable item' do |t|
      t.timestamps
      t.uuid :uuid
      t.integer :parent_id
      t.references :user, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.references :agent, foreign_key: { on_update: :cascade, on_delete: :nullify }
      t.inet :ip
      t.boolean :visible, default: true, null: false
      t.boolean :locked, default: false, null: false
      t.boolean :deleted, default: false, null: false
      t.boolean :spam, default: false, null: false
      t.boolean :approved, default: true, null: false
      t.integer :commentable_id, null: false
      t.string :commentable_type, null: false
      t.string :author_name
      t.string :author_email
      t.text :body, null: false
      t.jsonb :data, default: {}, null: false
    end

    add_index :comments, :uuid, unique: true
    add_index :comments, :data, using: :gin
    add_index :comments, %i[commentable_id commentable_type]
    add_index :comments, %i[approved agent_id ip]
    add_foreign_key :comments, :comments, column: :parent_id, on_update: :cascade, on_delete: :cascade

    execute %(
      create index if not exists
        comments_search_idx on comments
        using gin(to_tsvector('russian', body));
    )
  end

  def create_component_record
    slug = Biovision::Components::CommentsComponent.slug
    return if BiovisionComponent.exists?(slug: slug)

    BiovisionComponent.create!(
      slug: slug,
      settings: {
        auto_approve_threshold: 3,
        body_limit: 5000,
        premoderation: false,
        spam_link_threshold: 0,
        trap_spam: true
      }
    )
  end
end
