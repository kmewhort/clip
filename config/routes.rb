Clip::Application.routes.draw do
  resources :licences
  match 'licences/:id/compare/:compare_to_id' => 'licences#compare'

  root to: "home#index"
end
