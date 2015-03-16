class Api::CommentsController < ApplicationController
  before_action :set_comment, only: [:update, :destroy]

  def index
    @comments = Comment.all
    render json: @comments
  end

  def create
    if comment = Comment.create!(create_params)
      @comments = Comment.all
      render json: @comments
    else
      render json: { errors: comment.errors.full_messages }
    end
  end

  def update
    if @comment.delete
      render json: { success: 'update complete successfully.' }
    else
      render json: { errors: @comment.errors.full_messages }
    end
  end

  def destroy
    if @comment.delete
      render json: { success: 'destroy complete successfully.' }
    else
      render json: { errors: @comment.errors.full_messages }
    end
  end

  private

  def create_params
    params.require(:comment).permit(:author, :text)
  end

  def set_comment
    @comment = Comment.find(params[:id])
  end

end
