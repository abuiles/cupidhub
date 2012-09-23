class LandingPageController < ApplicationController
  def index
    redirect_to hackers_url if current_user
  end
end
