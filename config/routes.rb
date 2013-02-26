Clip::Application.routes.draw do
  resources :licences
  root to: "home#index"
end
