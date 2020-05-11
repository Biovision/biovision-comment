# frozen_string_literal: true

# Comments
class CommentsController < ApplicationController
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

  # get /comments/:id
  def show
    redirect_to(admin_comment_path(id: params[:id]))
  end

  private

  def component_class
    Biovision::Components::CommentsComponent
  end

  def restrict_access
    error = 'Managing comments is not allowed'
    handle_http_401(error) unless component_handler.allow?('moderator')
  end

  def emulate_creation
    form_processed_ok(root_path)
  end

  def create_comment
    verify_captcha_and_create
    if @entity.valid?
      flash[:notice] = t('comments.create.premoderation') unless @entity.approved?
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

  def entity_parameters
    params.require(:comment).permit(Comment.entity_parameters)
  end

  def creation_parameters
    permitted = Comment.creation_parameters
    params.require(:comment).permit(permitted).merge(owner_for_entity(true))
  end

  protected

  def verify_captcha_and_create
    if component_handler.use_captcha?
      @entity = Comment.new
      verified = verify_recaptcha(model: @entity)
    else
      verified = true
    end

    @entity = component_handler.create_comment(creation_parameters) if verified
  end
end
