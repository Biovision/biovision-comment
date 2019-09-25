# frozen_string_literal: true

# Comment
#
# Attributes:
#   agent_id [Agent], optional
#   approved [Boolean]
#   author_email [String], optional
#   author_name [String], optional
#   body [Text]
#   commentable_id [Integer]
#   commentable_type [String]
#   created_at [DateTime]
#   deleted [Boolean]
#   downvote_count [Integer]
#   ip [Inet], optional
#   locked [Boolean]
#   parent_id [Comment], optional
#   spam [Boolean]
#   updated_at [DateTime]
#   upvote_count [Integer]
#   visible [Boolean]
#   vote_result [Integer]
class Comment < ApplicationRecord
  include Checkable
  include HasOwner
  include Toggleable
  include VotableItem if Gem.loaded_specs.key?('biovision-vote')

  AUTHOR_LIMIT = 100
  BODY_LIMIT = 1_048_576

  toggleable :visible

  belongs_to :user, optional: true
  belongs_to :agent, optional: true
  belongs_to :commentable, polymorphic: true, counter_cache: true, touch: false
  belongs_to :parent, class_name: Comment.to_s, optional: true
  has_many :child_comments, class_name: Comment.to_s, foreign_key: :parent_id, dependent: :destroy

  validates_presence_of :body
  validates_length_of :body, maximum: BODY_LIMIT
  validates_length_of :author_name, maximum: AUTHOR_LIMIT
  validates_length_of :author_email, maximum: AUTHOR_LIMIT
  validate :commentable_is_commentable

  after_create { commentable.comment_impact(self) if commentable.respond_to?(:comment_impact) }

  scope :recent, -> { order 'id desc' }
  scope :chronological, -> { order 'id asc' }
  scope :approved, -> { where(approved: true) }
  scope :visible, -> { approved.where(deleted: false, visible: true, spam: false) }
  scope :list_for_administration, -> { recent }
  scope :list_for_visitors, -> { visible.chronological }
  scope :list_for_visitors_recent, -> { visible.recent }
  scope :list_for_owner, ->(v) { owned_by(v).where(deleted: false).recent }

  # @param [Integer] page
  def self.page_for_administration(page = 1)
    list_for_administration.page(page)
  end

  # @param [Integer] page
  def self.page_for_visitor(page = 1)
    list_for_visitors.page(page)
  end

  # @param [User] user
  # @param [Integer] page
  def self.page_for_owner(user, page = 1)
    list_for_owner(user).page(page)
  end

  def self.entity_parameters
    %i[author_name author_email body]
  end

  def self.creation_parameters
    entity_parameters + %i[commentable_id commentable_type parent_id]
  end

  def self.administrative_parameters
    entity_parameters + %i[deleted visible spam]
  end

  def self.tree(collection)
    result = {}

    collection.each do |entity|
      result[entity.id] = {
        parent_id: entity.parent_id,
        comment: entity,
      }
    end

    result
  end

  # @param [User] user
  def visible_to?(user)
    if commentable.respond_to? :visible_to?
      if deleted?
        UserPrivilege.user_has_privilege?(user, :administrator) && commentable.visible_to?(user)
      else
        commentable.visible_to?(user)
      end
    else
      !deleted? || UserPrivilege.user_has_privilege?(user, :administrator)
    end
  end

  def notify_entry_owner?
    entry_owner = commentable.user
    if entry_owner.is_a?(User) && !owned_by?(entry_owner)
      entry_owner.can_receive_letters?
    else
      false
    end
  end

  def text_for_link
    "#{self.class.model_name.human} #{id}"
  end

  def commentable_name
    "#{commentable.class.model_name.human} #{commentable_id}"
  end

  def commentable_title
    if commentable.respond_to?(:title)
      commentable.title
    else
      commentable_name
    end
  end

  def profile_name
    user.nil? ? author_name : user.profile_name
  end

  private

  def commentable_is_commentable
    return unless commentable.respond_to?(:commentable_by?)
    return if commentable.commentable_by?(user)

    errors.add(:commentable, I18n.t('activerecord.errors.models.comment.attributes.commentable.not_commentable'))
  end
end
