Mankatha::Application.routes.draw do
  root :to => 'outbound_travels#index'

  get 'log_out' => 'sessions#destroy'
  get 'log_in' => 'sessions#new'
  get 'sign_up' => 'users#new'

  resources :users
  resources :sessions

  # TODO: These should be merged into the respective resource blocks if possible
  match 'expense_settlement/upload' => 'expense_settlement#upload'
  match 'outbound_travels/index/:page' => 'outbound_travels#index'
  match 'profiles/search_by_name' => 'profiles#search_by_name'
  match 'profiles/search_by_id' => 'profiles#search_by_id'

  match 'forex_payments/index/:page' => 'forex_payments#index'
  resources :forex_payments do
    collection do
      get :search
      get :export
      get :data_to_suggest
    end
  end

  resources :forex_reports do
    collection do
      get :search
      get :export
    end
  end

  resources :outbound_travels do
    collection do
      get :search
      get :export
      get :data_to_suggest
      get :get_recent
      get :travels_without_return_date
    end
    member do
      post :update_field
    end
  end

  resources :expense_settlement do
    member do
      post :notify
    end
  end

  # TODO: This is BAD
  match ':controller(/:action(/:id(.:format)))'
end
