# frozen_string_literal: true

module Biovision
  module Components
    # Handler for Biovision Comments
    class CommentsComponent < BaseComponent
      SLUG = 'comments'

      def self.privilege_names
        %w[moderator]
      end

      def use_parameters?
        false
      end

      # @param [Hash] parameters
      def create_comment(parameters)
        @comment = ::Comment.new(parameters)
        @comment.approved = approval_flag if settings['premoderation']
        @comment.save
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
