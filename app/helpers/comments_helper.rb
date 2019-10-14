# frozen_string_literal: true

# Helper methods for handling comments
module CommentsHelper
  # @param [Comment] entity
  # @param [String] text
  # @param [Hash] options
  def admin_comment_link(entity, text = entity.text_for_link, options = {})
    link_to(text, admin_comment_path(id: entity.id), options)
  end

  # @param [Comment] entity
  # @param [String] text
  # @param [Hash] options
  def comment_link(entity, text = entity.commentable_name, options = {})
    anchor = options.key?(:anchor)
    options.delete(:anchor)
    path = Biovision::Components::CommentsComponent.commentable_path(entity, anchor)
    link_to(text, path, options)
  end
end
