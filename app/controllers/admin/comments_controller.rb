class Admin::CommentsController < AdminController
  include ToggleableEntity
  include LockableEntity

  before_action :set_entity, except: [:index]

  # get /admin/comments
  def index
    @collection = Comment.page_for_administration(current_page)
  end

  # get /admin/comments/:id
  def show
  end

  protected

  def restrict_access
    require_privilege :moderator
  end

  def set_entity
    @entity = Comment.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find comment')
    end
  end
end
