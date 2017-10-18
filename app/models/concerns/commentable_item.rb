module CommentableItem
  extend ActiveSupport::Concern

  included do
    has_many :comments, as: :commentable, dependent: :destroy
  end

  # @param [User] user
  def commentable_by?(user)
    !user.nil?
  end
end
