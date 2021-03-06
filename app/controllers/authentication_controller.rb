class AuthenticationController < ApplicationController
  def create
    auth = request.env["omniauth.auth"]
    reset_session

    hacker = Hacker.where(github_uid: auth.uid).
      first_or_create(
        name: auth.info.name,
        github_user: auth.info.nickname,
        github_token: auth.credentials.token,
        email: auth.info.email,
        image_url: auth.info.image
      )

    session[:hacker] = hacker
    redirect_to hackers_url
  end

  def destroy
    session[:hacker] = nil
    reset_session
    redirect_to root_url
  end

  def failure
    render "bummer! authentication failed"
  end
end
