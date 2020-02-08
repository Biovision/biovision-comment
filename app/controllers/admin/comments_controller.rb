# frozen_string_literal: true

# Administrative handling comments
class Admin::CommentsController < AdminController
  include ToggleableEntity
  include LockableEntity

  before_action :set_entity, except: :index

  # get /admin/comments
  def index
    @collection = Comment.page_for_administration(current_page)
  end

  # get /admin/comments/:id
  def show
  end

  # put /admin/comments/:id/approve
  def approve
    @entity.update(approved: true)
    component_handler.class.notify(@entity)

    head :no_content
  end

  def destroy
    @entity.destroy

    head :no_content
  end

  protected

  def component_class
    Biovision::Components::CommentsComponent
  end

  def restrict_access
    error = 'Managing comments is not allowed'
    handle_http_401(error) unless component_handler.allow?('moderator')
  end

  def set_entity
    @entity = Comment.find_by(id: params[:id])
    handle_http_404('Cannot find comment') if @entity.nil?
  end
end
