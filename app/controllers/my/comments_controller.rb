class My::CommentsController < ApplicationController
  before_action :restrict_anonymous_access

  # get /my/comments
  def index
    @collection = Comment.page_for_owner(current_user, current_page)
  end
end
