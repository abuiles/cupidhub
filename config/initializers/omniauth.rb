Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, "98b371bdfb3f6167e066", "31cf587743716d2ebc26c35073978b3bc8bd6f73"
end
