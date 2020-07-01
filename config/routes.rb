Rails.application.routes.draw do
  post '/callback' => 'rainbot#callback'
end
