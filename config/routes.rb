Hoptopus::Application.routes.draw do
  match 'cellars/import-failed' => 'cellars#import_failed', :as => 'cellar_upload_failed'

  resources :cellars, :only => [:index, :show] do
    member do
      post 'upload'
    end
    
    resources :beers do
      resources :comments, :only => [:update, :destroy, :create]
      resources :tastings, :only => [:new, :create]
    end
    
    resources :comments, :only => [:update, :destroy, :create]
  end

  resources :brews do
    resources :tastings, :only => [:show, :update, :destroy, :edit] do
      resources :comments, :only => [:update, :destroy, :create]
    end
  end
  
  resources :users, :only => :update

  resources :breweries, :except => :show
  
  resources :contact, :only => [:index, :create]
  
  match 'login' => 'auth#login'
  match 'register' => 'auth#register'
  match 'logout' => 'auth#logout'
  match 'reset-password' => 'auth#request_password_reset', :as => 'request_password_reset'
  match 'reset-password/sent' => 'auth#password_reset_confirmation_sent', :as => 'password_reset_confirmation_sent'
  match 'reset-password/:id' => 'auth#confirm_password_reset', :as => 'confirm_password_reset'
  match 'contact/sent' => 'contact#sent', :as => 'contact_request_sent'
  match 'newsletter/signup' => 'newsletter#signup', :as => 'newsletter_signup'
  match 'cellars/:id/upload/confirm' => 'cellars#confirm_import', :as => 'confirm_upload_cellar'
  match 'cellars/:id/import-status' => 'cellars#import_status', :as => 'cellar_import_status'

  root :to => "home#index"
end
