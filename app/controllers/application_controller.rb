class ApplicationController < ActionController::Base
  protect_from_forgery

  def current_user
    @current_user = session[:hacker]
  end
  
  def require_authentication
    redirect_to root_url unless current_user.present?
  end
end


