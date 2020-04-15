# frozen_string_literal: true

# API for user children
class Api::V1::ChildrenController < Api::V1::ApiController
  before_action :set_child, only: %i[show update destroy]

  # GET /children
  def index
    @children = Child.all

    render json: @children
  end

  # GET /children/:slug
  def show
    render json: @child
  end

  # POST /children
  def create
    @child = Child.new(child_params)

    if @child.save
      render json: @child, status: :created, location: @child
    else
      render json: @child.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /children/:slug
  def update
    if @child.update(child_params)
      render json: @child
    else
      render json: @child.errors, status: :unprocessable_entity
    end
  end

  # DELETE /children/:slug
  def destroy
    # soft delete
    @child.update!(active: false)
  end

  private

  def set_child
    @child = Child.find_by!(slug: params[:slug])
  end

  def child_params
    params.require(:child).permit(
      :active, :ccms_id, :date_of_birth, :first_name, :full_name, :id, :last_name, :slug, :user_id
    )
  end
end
