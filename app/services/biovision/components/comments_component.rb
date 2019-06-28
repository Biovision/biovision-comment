# frozen_string_literal: true

module Biovision
  module Components
    # Handler for Biovision Comments
    class CommentsComponent < BaseComponent
      SLUG = 'comments'

      # @param [Hash] parameters
      def create_comment(parameters)
        @comment = ::Comment.new(parameters)
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
    end
  end
end
