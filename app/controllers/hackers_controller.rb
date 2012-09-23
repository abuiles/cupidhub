class HackersController < ApplicationController
  before_filter :require_authentication
  respond_to :json, only: [:recommended_hackers, :recommended_projects, :hacker_similarity]

  def index
    @hackers = Hacker.all
    @hacker  = current_user if current_user.present?
  end
end
