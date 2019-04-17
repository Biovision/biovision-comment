# frozen_string_literal: true

# Tool for handling comments
class CommentsManager
  # @param [Comment] comment
  # @param [TrueClass|FalseClass] anchor
  def self.commentable_path(comment, anchor = false)
    method_name = "#{comment.commentable_type}_path".downcase.to_sym
    if respond_to?(method_name)
      result = send(method_name, comment.commentable)
      anchor ? "#{result}#comment-#{comment.id}" : result
    else
      "##{method_name}"
    end
  end

  # @param [Post] entity
  def self.post_path(entity)
    return '#post' unless Gem.loaded_specs.key?('biovision-post')

    handler = PostManager.new(entity)
    handler.post_path
  end
end
