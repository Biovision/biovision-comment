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

      # @param [Hash|Comment] data
      def create_comment(data)
        @comment = data.is_a?(::Comment) ? data : ::Comment.new(data)
        limit_comment_body
        @comment.approved = approval_flag if settings['premoderation']
        trap_spam if settings['trap_spam']
        @comment.save unless ignore?
        self.class.notify(@comment) if @comment.approved?

        @comment
      end

      def use_captcha?
        return false unless settings['recaptcha']
        return false unless Gem.loaded_specs.key?('recaptcha')
        return true if user.nil?

        gate = settings['auto_approve_threshold'].to_i
        positive = ::Comment.where(user: user, approved: true).count
        negative = ::Comment.where(user: user, approved: false).count
        positive - negative < gate
      end

      protected

      # @param [Hash] data
      # @return [Hash]
      def normalize_settings(data)
        result = {}
        flags = %w[premoderation trap_spam recaptcha ignore_spam]
        flags.each { |f| result[f] = data[f].to_i == 1 }
        numbers = %w[auto_approve_threshold body_limit spam_link_threshold]
        numbers.each { |f| result[f] = data[f].to_i }
        strings = %w[spam_pattern]
        strings.each { |f| result[f] = data[f].to_s }

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
        @comment.approved = !spam?
      end

      def spam?
        pattern = settings['spam_pattern']
        return false if pattern.blank?

        threshold = settings['spam_link_threshold'].to_i

        @comment.body.scan(Regexp.new(pattern, 'i')).length > threshold
      rescue RegexpError => e
        Rails.logger.warn(e)
        false
      end

      def ignore?
        settings['ignore_spam'] && spam?
      end

      def limit_comment_body
        body_limit = @component.settings['body_limit'].to_i
        body_limit = 5000 if body_limit < 1
        body_limit -= 1

        @comment.body = @comment.body.to_s[0..body_limit]
      end
    end
  end
end
