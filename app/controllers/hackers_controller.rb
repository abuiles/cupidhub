class HackersController < ApplicationController
  def index
    puts "HELLO  HACKERS"
    github = Github.new
    @user = 'scastillo'
    @followers = github.users.followers.following @user
  end
end
