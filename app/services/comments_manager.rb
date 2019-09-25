# frozen_string_literal: true

# Tool for handling comments
class CommentsManager
  # @param [Comment] comment
  # @param [TrueClass|FalseClass] anchor
  def self.commentable_path(comment, anchor = false)
    method_name = "#{comment.commentable_type}_path".downcase.to_sym
    if comment.commentable.respond_to?(:url)
      result = comment.commentable.url
      anchor ? "#{result}#comment-#{comment.id}" : result
    else
      "##{method_name}"
    end
  end
end
