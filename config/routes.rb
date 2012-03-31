# TODO: Need to review and limit routes to only those methods that are implemented (eg using 'only')
# TODO: Need to review and set the method (POST vs GET va DELETE) appropriately
Mankatha::Application.routes.draw do
  root :to => 'outbound_travels#index'

  resources :users, :only => [:new, :create]
  resources :sessions, :only => [:new, :create, :destroy]     # TODO: Usually, you dont expose the session directly - its just a mechanism to validate and carry current login state

  resources :forex_payments do
    collection do
      get :export
      get :data_to_suggest
    end
  end

  resources :forex_reports, :only => [:index] do
    collection do
      get :export
    end
  end

  resources :outbound_travels do
    collection do
      get :export
      get :data_to_suggest
      get :get_recent
      get :travels_without_return_date
    end
    member do
      post :update_field
    end
  end

  resources :expense_settlements do
    collection do
      get  :show_uploads
      post :generate_report
      post :file_upload
      post :delete_cash_handover
    end
    member do
      get :load_by_travel
      post :notify
      post :set_processed
    end
  end

  resources :consolidated_expenses, :only => [:index] do
    collection do
      get :export
      get :mark_processed_and_export
    end
  end

  resources :expense_reimbursements, :only => [:index, :show, :edit] do
    collection do
      post :process_reimbursement
    end
  end

  resources :profiles, :only => [] do
    collection do
      get :search_by_name
      get :search_by_id
    end
  end

  resources :reports, :only => [:index]
end
