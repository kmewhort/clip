Clip::Application.routes.draw do
  devise_for :admins

  # licences
  resources :licences, :id => /[A-Za-z0-9\.\-]+?/, :format => /html|json|js/ do #allow periods in id
    member do
      get 'compare_to'
    end
  end

  resources :family_trees

  resources :compatibilities, :id => /[A-Za-z0-9\.\-]+?/, :format => /html|json|js/ do
    member do
      get 'matrix'
    end
  end

  # non-resourceful routes
  root to: "home#index"
  match 'api' => "home#api"
  match 'tools/compare' => "tools#compare"
  match 'tools/benchmark' => "tools#benchmark"
end
