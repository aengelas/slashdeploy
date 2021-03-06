# The primary controller that all controllers inherit from.
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # By default, all actions should require authentication. Individual actions
  # can opt-out using `skip_before_action`.
  before_action :authenticate!

  def current_user
    warden.user
  end
  helper_method :current_user

  def signed_in?
    warden.authenticated?
  end
  helper_method :signed_in?

  def authenticate!
    redirect_to login_path unless signed_in?
  end

  private

  def warden
    request.env['warden']
  end
end
