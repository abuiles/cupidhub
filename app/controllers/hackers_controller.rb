class HackersController < ApplicationController
  before_filter :require_authentication
  respond_to :json, only: [:recommended_hackers, :recommended_projects, :hacker_similarity]

  def index
    @hackers = Hacker.all
    @hacker  = current_user if current_user.present?
    if @hacker
      @hacker = Hacker.find_by_id @hacker.id
    end
  end

  def recommended_hackers
    user = Hacker.find_by_id!(params[:id])
    recommendations = user.recommended_hackers
    respond_with recommendations
  end

  def recommended_projects
    user = Hacker.find_by_id!(params[:id])
    recommendations = user.recommended_projects

    respond_with recommendations
  end

  def hacker_similarity
    user   = Hacker.find_by_id!(params[:id])
    hacker = Hacker.find_by_id!(params[:hacker_id])
    similarity = user.hacker_similarity(hacker.github_uid)

    respond_with similarity
  end
end
