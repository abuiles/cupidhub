Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV['GITMATCH_GH_CLIENT_ID'], ENV['GITMATCH_GH_CLIENT_SECRET']
end
