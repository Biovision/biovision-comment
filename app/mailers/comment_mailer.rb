# frozen_string_literal: true

# Mailer for sending comment notifications
class CommentMailer < ApplicationMailer
  # @param [Integer] comment_id
  def entry_reply(comment_id)
    @comment = Comment.find_by(id: comment_id)

    return if @comment.nil?

    user = @comment.commentable.user

    mail(to: user.email) if user.can_receive_letters?
  end

  # @param [Integer] comment_id
  def comment_reply(comment_id)
    @comment = Comment.find_by(id: comment_id)

    return if @comment.nil?

    user = @comment.parent.user

    mail(to: user.email) if user.can_receive_letters?
  end
end
