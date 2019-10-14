# frozen_string_literal: true

module Biovision
  module Components
    # Handler for Biovision Comments
    class CommentsComponent < BaseComponent
      SLUG = 'comments'

      def self.privilege_names
        %w[moderator]
      end

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

      # @param [Comment] comment
      def self.notify(comment)
        return if comment.data['notified']

        parent = comment.parent
        if parent.nil?
          CommentMailer.entry_reply(comment.id).deliver_later if comment.notify_entry_owner?
        else
          CommentMailer.comment_reply(comment.id).deliver_later if comment.notify_parent_owner?
        end

        comment.data['notified'] = true
        comment.save
      end

      def use_parameters?
        false
      end

      # @param [Hash] parameters
      def create_comment(parameters)
        @comment = ::Comment.new(parameters)
        @comment.approved = approval_flag if settings['premoderation']
        @comment.save
        self.class.notify(@comment) if @comment.approved?

        @comment
      end

      protected

      # @param [Hash] data
      # @return [Hash]
      def normalize_settings(data)
        result = {}
        flags  = %w[premoderation]
        flags.each { |f| result[f] = data[f].to_i == 1 }
        numbers = %w[auto_approve_threshold]
        numbers.each { |f| result[f] = data[f].to_i }

        result
      end

      def approval_flag
        threshold = settings['auto_approve_threshold']
        if @comment.user.nil?
          criteria = {
            user_id: nil,
            ip: @comment.ip,
            agent_id: @comment.agent_id
          }
          ::Comment.approved.where(criteria).count >= threshold
        else
          ::Comment.approved.owned_by(@comment.user).count >= threshold
        end
      end
    end
  end
end
