class Comment < ApplicationRecord
  include HasOwner
  include Toggleable
  include VotableItem if 'Vote'.safe_constantize

  PER_PAGE   = 20
  BODY_LIMIT = 5000

  toggleable :visible

  belongs_to :user, optional: true, counter_cache: true, touch: false
  belongs_to :agent, optional: true
  belongs_to :commentable, polymorphic: true, counter_cache: true, touch: false

  validates_presence_of :body
  validates_length_of :body, maximum: BODY_LIMIT
  validate :commentable_is_commentable

  scope :recent, -> { order 'id desc' }
  scope :visible, -> { where(deleted: false, visible: true) }

  # @param [Integer] page
  def self.page_for_administration(page)
    recent.page(page).per(PER_PAGE)
  end

  # @param [Integer] page
  def self.page_for_visitor(page)
    recent.visible.page(page).per(PER_PAGE)
  end

  # @param [User] user
  # @param [Integer] page
  def self.page_for_owner(user, page)
    owned_by(user).where(deleted: false).recent.page(page).per(PER_PAGE)
  end

  def self.entity_parameters
    %i(body)
  end

  def self.creation_parameters
    entity_parameters + %i(commentable_id commentable_type)
  end

  def self.administrative_parameters
    entity_parameters + %i(deleted)
  end

  # @param [User] user
  def visible_to?(user)
    if self.commentable.respond_to? :visible_to?
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

  private

  def commentable_is_commentable
    if self.commentable.respond_to? :commentable_by?
      unless self.commentable.commentable_by? self.user
        errors.add(:commentable, I18n.t('activerecord.errors.models.comment.attributes.commentable.not_commentable'))
      end
    end
  end
end
