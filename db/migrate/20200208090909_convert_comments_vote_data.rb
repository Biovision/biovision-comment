# frozen_string_literal: true

# Move vote component fields into data
class ConvertCommentsVoteData < ActiveRecord::Migration[5.2]
  def up
    return unless column_exists?(:comments, :vote_result)

    add_column :comments, :uuid, :uuid

    Comment.order('id asc').each do |comment|
      comment.data['votes'] = {
        up: comment.upvote_count,
        down: comment.downvote_count,
        total: comment.vote_result
      }
      comment.save!
    end

    remove_column :comments, :upvote_count
    remove_column :comments, :downvote_count
    remove_column :comments, :vote_result
  end

  def down
    # No rollback needed
  end
end
