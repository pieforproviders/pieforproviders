# frozen_string_literal: true

# API for user children
class Api::V1::ChildrenController < Api::V1::ApiController
  before_action :set_user
  before_action :set_user_child, only: %i[show update destroy]

  # GET /users/:user_id/children
  def index
    render json: @user.children
  end

  # GET /users/:user_id/children/:child_id
  def show
    render json: @child
  end

  # POST /users/:user_id/children
  def create
    child = @user.children.create!(child_params)

    if child.save
      render json: @user, include: :children, status: :created, location: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/:user_id/children/:child_id
  def update
    if @child.update(child_params)
      render json: @user, include: :children
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/:user_id/children/:child_id
  def destroy
    # soft delete
    @child.update!(active: false)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.includes(:children).find(params[:user_id])
  end

  def set_user_child
    @child = @user.children.find_by!(id: params[:id]) if @user
  end

  def child_params
    params.require(:child).permit(
      :active, :ccms_id, :date_of_birth, :first_name, :full_name, :id, :last_name, :user_id
    )
  end
end
