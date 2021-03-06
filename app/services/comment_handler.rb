# frozen_string_literal: true

# Handler for working with comments
class CommentHandler
  attr_accessor :user

  # @param [User] user
  def initialize(user = nil)
    @user = user
    @handler = Biovision::Components::CommentsComponent[user]
  end

  # Get list of comments for entity
  #
  # Depending on privileges, receives list for visitors (only visible
  # and approved) or all comments (including deleted).
  #
  # @param [ApplicationRecord] entity
  def list(entity)
    if @handler.allow?
      entity.comments.list_for_administration
    else
      entity.comments.list_for_visitors
    end
  end

  # Auto-approve comment from current user?
  #
  # If premoderation flag is not set, every comment is automatically approved.
  # If premoderation flag is set, difference between approved and non-approved
  # comments must be more than threshold; anonymous comments are always
  # non-approved.
  def approve?
    return true unless @handler.settings['premoderate']
    return false if @user.nil?
    return true if @handler.allow?

    gate = @handler.settings['auto_approve_threshold'].to_i
    positive = Comment.where(user: @user, approved: true).count
    negative = Comment.where(user: @user, approved: false).count
    positive - negative >= gate
  end

  # @param [String] privilege_name
  def allow?(*privilege_name)
    @handler.allow?(*privilege_name)
  end

  # @param [ApplicationRecord] entity
  def allow_reply?(entity)
    entity.respond_to?(:commentable_by?) && entity.commentable_by?(@user)
  end
end
