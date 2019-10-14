
# Preview all emails at http://localhost:3000/rails/mailers/feedback
class CommentPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/comment/entry_reply
  def entry_reply
    CommentMailer.entry_reply(Comment.where(parent_id: nil).last.id)
  end

  # Preview this email at http://localhost:3000/rails/mailers/comment/comment_reply
  def comment_reply
    CommentMailer.comment_reply(Comment.where('parent_id is not null').last.id)
  end
end
