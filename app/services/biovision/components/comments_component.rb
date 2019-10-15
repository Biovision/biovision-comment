# frozen_string_literal: true

module Biovision
  module Components
    # Handler for Biovision Comments
    class CommentsComponent < BaseComponent
      SLUG = 'comments'
      SPAM_PATTERN = %r{https?://[a-z0-9]+}i.freeze

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

        if comment.parent.nil?
          if comment.notify_entry_owner?
            CommentMailer.entry_reply(comment.id).deliver_later
          end
        elsif comment.notify_parent_owner?
          CommentMailer.comment_reply(comment.id).deliver_later
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
        trap_spam if settings['trap_spam']
        @comment.save
        self.class.notify(@comment) if @comment.approved?

        @comment
      end

      protected

      # @param [Hash] data
      # @return [Hash]
      def normalize_settings(data)
        result = {}
        flags = %w[premoderation trap_spam]
        flags.each { |f| result[f] = data[f].to_i == 1 }
        numbers = %w[auto_approve_threshold spam_link_threshold]
        numbers.each { |f| result[f] = data[f].to_i }

        result
      end

      def approval_flag
        threshold = settings['auto_approve_threshold']
        if @comment.user.nil?
          criteria = {
            agent_id: @comment.agent_id, ip: @comment.ip, user_id: nil
          }
          ::Comment.approved.where(criteria).count >= threshold
        else
          ::Comment.approved.owned_by(@comment.user).count >= threshold
        end
      end

      def trap_spam
        threshold = settings['spam_link_threshold'].to_i
        return unless @comment.body.scan(SPAM_PATTERN).length > threshold

        @comment.approved = false
      end
    end
  end
end
