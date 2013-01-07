Clip::Application.routes.draw do
  resources :changes_to_terms
  resources :conflict_of_laws
  resources :disclaimers
  resources :licence_changes
  resources :terminations
  resources :compatibilities
  resources :copyleft_clauses
  resources :attribution_clauses
  resources :patent_clauses
  resources :obligations
  resources :rights
  resources :compliances
  resources :licences do
    member do
      put 'preview', action: 'edit_preview'
    end
    collection do
      post 'preview', action: 'new_preview'
    end
  end
end
