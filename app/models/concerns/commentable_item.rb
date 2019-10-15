# frozen_string_literal: true

# Adds "commentable" behavior to entity
module CommentableItem
  extend ActiveSupport::Concern

  included do
    has_many :comments, as: :commentable, dependent: :destroy
  end

  # @param [User] user
  def commentable_by?(user)
    respond_to?(:visible_to?) ? visible_to?(user) : !user.nil?
  end
end
