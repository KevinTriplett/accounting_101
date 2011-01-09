Accounting_101::Application.routes.draw do
  # named routes

  # singleton resources

  # resources
  resources :accounts
  resources :postings
  resources :journals
  resources :batches
  resources :type_of_assets
  resources :type_of_accounts

  # namespaced routes

end
