# frozen_string_literal: true

# API for children receiving care
class Api::V1::ChildrenController < Api::V1::ApiController                 
  before_action :set_child, only: %i[show update destroy]

  # GET /children
  def index
    @children = Child.all

    render json: @children
  end

  # GET /children/1
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

  # PATCH/PUT /children/1
  def update
    if @child.update(child_params)
      render json: @child
    else
      render json: @child.errors, status: :unprocessable_entity
    end
  end

  # DELETE /children/1
  def destroy
    @child.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_child
    @child = Child.find(params[:id])
  end

  def child_params
    params.require(:child).permit(
      :id,
      :active,
      :date_of_birth,
      :full_name,
      :greeting_name,
      user_ids: []
    )
  end
end
