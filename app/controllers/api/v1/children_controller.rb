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

  # GET /case_list_for_dashboard
  def case_list_for_dashboard
    @children = policy_scope(Child.active.with_current_approval)

    if current_user.state == 'NE'
      render json: ChildBlueprint.render(@children, view: :nebraska_dashboard)
    else
      render json: ChildBlueprint.render(@children, view: :illinois_dashboard)
    end
  end

  # POST /children
  def create
    @child = Child.new(child_params)

    if @child.save
      make_illinois_approval_amounts
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
    attributes = []
    attributes += %i[active] if current_user.admin?
    attributes += [
      :date_of_birth,
      :full_name,
      :business_id,
      { approvals_attributes: %i[case_number copay copay_frequency effective_on expires_on] }
    ]
    params.require(:child).permit(attributes)
  end

  def make_illinois_approval_amounts
    month_amounts = params.select { |key| key.to_s.start_with?('month') }
    first_month = params['first_month_name']
    year = params['first_month_year']
    return if month_amounts.empty? || [first_month, year].all?(&:nil?)

    ApprovalAmountGenerator.new(@child, month_amounts, first_month, year).call
  end
end
