class HackersController < ApplicationController
  def index
    @hackers = Hacker.all
    @hacker  = current_user if current_user
  end
end
