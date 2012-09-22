class HackersController < ApplicationController
  respond_to :json, only: [:recommended_hackers, :recommended_projects]

  def index
    @hackers = Hacker.all
    @hacker  = current_user if current_user
  end

  def recommended_hackers
    recommendations = current_user.recommended_hackers
    respond_with recommendations
  end

  def recommended_projects
    recommendations = current_user.recommended_projects
    respond_with recommendations
  end
end
