# frozen_string_literal: true

# Add full-text search for comments
class AddSearchIndexToComments < ActiveRecord::Migration[5.2]
  def up
    execute %(
      create index if not exists
        comments_search_idx on comments 
        using gin(to_tsvector('russian', body));
    )
  end

  def down
    execute %(drop index if exists comments_search_idx)
  end
end
