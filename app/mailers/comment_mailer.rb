class CommentMailer < ApplicationMailer
  # @param [Integer] comment
  def entry_reply(comment_id)
    @comment = Comment.find_by(id: comment_id)

    mail to: @comment.commentable.user.email unless @comment.nil?
  end
end
