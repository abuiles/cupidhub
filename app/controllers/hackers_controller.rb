require 'json'
class HackersController < ApplicationController
  before_filter :require_authentication
  def index
    @hackers = Hacker.all
    @hacker  = current_user if current_user.present?
  end
end
