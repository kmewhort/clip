Clip::Application.routes.draw do
  resources :licences do
    member do
      put 'preview', action: 'edit_preview'
    end
    collection do
      post 'preview', action: 'new_preview'
    end
    resources :scores
  end
end
