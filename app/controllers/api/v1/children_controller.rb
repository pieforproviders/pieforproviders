# frozen_string_literal: true

# API for user children
class Api::V1::ChildrenController < Api::V1::ApiController
  before_action :set_child, only: %i[show update destroy]
  before_action :authorize_user, only: %i[update destroy]

  # GET /children
  def index
    @children = policy_scope(Child)

    render json: @children
  end

  # GET /children/:id
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

  # PATCH/PUT /children/:id
  def update
    if @child.update(child_params)
      render json: @child
    else
      render json: @child.errors, status: :unprocessable_entity
    end
  end

  # DELETE /children/:id
  def destroy
    # soft delete
    @child.update!(active: false)
  end

  private

  def set_child
    @child = policy_scope(Child).find(params[:id])
  end

  def authorize_user
    authorize @child
  end

  def child_params
    attributes = %i[date_of_birth
                    full_name
                    business_id]
    attributes += %i[active] if current_user.admin?
    params.require(:child).permit(attributes)
  end
end
