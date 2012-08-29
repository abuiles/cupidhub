class HackersController < ApplicationController
  def index
    @hackers = Hacker.all
  end
end
