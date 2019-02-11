# frozen_string_literal: true

# Comments
class CommentsController < ApplicationController
  before_action :restrict_access, except: :create
  before_action :set_entity, only: %i[show edit update destroy]

  layout 'admin', except: :create

  # post /comments/check
  def check
    @entity = Comment.instance_for_check(params[:entity_id], entity_parameters)

    render 'shared/forms/check'
  end

  # post /comments
  def create
    @entity = Comment.new creation_parameters
    if @entity.save
      notify_participants
      next_page = @entity.commentable || admin_comment_path(id: @entity.id)
      respond_to do |format|
        format.js { render(js: "document.location.reload(true)") }
        format.html { redirect_to(next_page) }
      end
    else
      form_processed_with_error(:new)
    end
  end

  # get /comments/:id
  def show
  end

  # get /comments/:id/edit
  def edit
  end

  # patch /comments/:id
  def update
    if @entity.update entity_parameters
      form_processed_ok(admin_comment_path(id: @entity.id))
    else
      form_processed_with_error(:edit)
    end
  end

  # delete /comments/:id
  def destroy
    if @entity.update deleted: true
      flash[:notice] = t('comments.destroy.success')
    end
    redirect_to(@entity.commentable || admin_comments_path)
  end

  private

  def restrict_access
    require_privilege :moderator
  end

  def set_entity
    @entity = Comment.find_by(id: params[:id])
    handle_http_404('Cannot find comment') if @entity.nil?
  end

  def entity_parameters
    permitted = if current_user_has_privilege?(:moderator, nil)
                  Comment.administrative_parameters
                else
                  Comment.entity_parameters
                end
    params.require(:comment).permit(permitted)
  end

  def creation_parameters
    permitted = Comment.creation_parameters
    params.require(:comment).permit(permitted).merge(owner_for_entity(true))
  end

  def notify_participants
    commentable = @entity.commentable
    unless commentable.owned_by?(current_user)
      category = Notification.category_from_object(commentable)
      Notification.notify(commentable.user, category, commentable.id)
      # begin
      #   Comments.entry_reply(@entity).deliver_now if @entity.notify_entry_owner?
      # rescue Net::SMTPAuthenticationError => error
      #   logger.warn error.message
      # end
    end
  end
end
