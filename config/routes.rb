Rails.application.routes.draw do
  root 'searches#search'
  get '/searches' => 'searches#show'
end
