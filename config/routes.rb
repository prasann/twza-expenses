Mankatha::Application.routes.draw do

  root :to => 'sessions#new'
  get 'log_out' => 'sessions#destroy'
  get 'log_in' => 'sessions#new'
  get 'sign_up' => 'users#new'
  resources :users
  resources :sessions

  match 'outbound_travels/index/:page' => 'outbound_travels#index'
  match 'forex_payments/index/:page' => 'forex_payments#index'
  match 'profiles/search_by_name' => 'profiles#search_by_name'
  match 'profiles/search_by_id' => 'profiles#search_by_id'
  match 'forex_payments/data_to_suggest' => 'forex_payments#data_to_suggest'
  match 'outbound_travels/data_to_suggest' => 'outbound_travels#data_to_suggest'

  resources :forex_payments do
    collection do
      get :search
    end
    collection do
      get  :export
    end
  end

  resources :forex_reports do
    collection do
      get :search
    end
    collection do
      get  :export
    end
  end

  resources :outbound_travels do
    collection do
      get  :search
    end
    collection do
      get  :export
    end
  end

  resources :expense_settlement do
    member do
      post  :notify
    end
  end
  match ':controller(/:action(/:id(.:format)))'
end
