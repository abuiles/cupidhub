class HackersController < ApplicationController
  def index
    @hackers = Hacker.all
    @hacker  = session[:hacker] if session[:hacker]
  end
end
