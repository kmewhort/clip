Clip::Application.routes.draw do
  # licences
  resources :licences, :id => /[A-Za-z0-9\.\-]+?/, :format => /html|json/ #allow periods in id
  match 'licences/:id/compare/:compare_to_id' => 'licences#compare'

  # non-resourceful routes
  root to: "home#index"
  match 'api' => "home#api"
end
