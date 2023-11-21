# frozen_string_literal: true

# Create Sessions when Users log in
class SessionsController < Devise::SessionsController
  respond_to :json

  def destroy
    request.cookie_jar.delete :_session_id

    super
  end

  private

  def respond_with(resource, _opts = {})
    render json: UserBlueprint.render(resource)
  end

  def respond_to_on_destroy
    head :no_content
  end
end
