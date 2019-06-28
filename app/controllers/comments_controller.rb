# frozen_string_literal: true

# Comments
class CommentsController < ApplicationController
  before_action :set_handler
  before_action :restrict_access, except: %i[check create]
  before_action :set_entity, only: %i[edit update destroy]

  layout 'admin', except: :create

  # post /comments/check
  def check
    @entity = Comment.instance_for_check(params[:entity_id], entity_parameters)

    render 'shared/forms/check'
  end

  # post /comments
  def create
    if params.key?(:agree)
      emulate_creation
    else
      create_comment
    end
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

  def emulate_creation
    form_processed_ok(root_path)
  end

  def create_comment
    @entity = @handler.create_comment(creation_parameters)
    if @entity.valid?
      notify_participants
      next_page = param_from_request(:return_url)
      form_processed_ok(next_page.match?(%r{\A/[^/]}) ? next_page : root_path)
    else
      form_processed_with_error(:new)
    end
  end

  def set_entity
    @entity = Comment.find_by(id: params[:id])
    handle_http_404('Cannot find comment') if @entity.nil?
  end

  def set_handler
    slug = Biovision::Components::CommentsComponent::SLUG
    @handler = Biovision::Components::BaseComponent.handler(slug)
  end

  def entity_parameters
    params.require(:comment).permit(Comment.entity_parameters)
  end

  def creation_parameters
    permitted = Comment.creation_parameters
    params.require(:comment).permit(permitted).merge(owner_for_entity(true))
  end

  def notify_participants
    # to be implemented...
  end
end
