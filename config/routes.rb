Hoptopus::Application.routes.draw do
  post "alerts/dismiss"

  # This needs to be up here so that it doesn't match the username rule thinger for below.
  match 'cellars/import-failed' => 'cellars#import_failed', :as => 'cellar_upload_failed'

  resources :cellars, :only => [:index, :show], :constraints => { :id => /.*/ } do
    member do
      post 'upload'
    end
    
    resources :beers do
      collection do
        post :edit
        put :update
      end

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

  resources :wiki, :only => :index
  
  resources :users, :only => :update, :constraints => { :id => /.*/ }
  resources :breweries, :except => :show
  resources :contact, :only => [:index, :create]
    
  namespace 'admin' do
    resources :users do
      collection do
        post 'makeadmin'
        post 'revokeadmin'
        post 'deleteuser'
        post 'disableuser'
      end
    end

    root :to => 'lobby#index'
  end
  
  # Shortcut URLs
  match 'login' => 'auth#login'
  match 'register' => 'auth#register'
  match 'logout' => 'auth#logout'
  
  # Special auth paths
  match 'reset-password' => 'auth#request_password_reset', :as => 'request_password_reset'
  match 'reset-password/sent' => 'auth#password_reset_confirmation_sent', :as => 'password_reset_confirmation_sent'
  match 'reset-password/:id' => 'auth#confirm_password_reset', :as => 'confirm_password_reset'
  
  # These are front end routes.
  match 'contact/sent' => 'contact#sent', :as => 'contact_request_sent'
  match 'newsletter/signup' => 'newsletter#signup', :as => 'newsletter_signup'

  # Special cellar paths
  match 'cellars/:id/upload/confirm' => 'cellars#confirm_import', :as => 'confirm_upload_cellar'
  match 'cellars/:id/import-status' => 'cellars#import_status', :as => 'cellar_import_status'
  
  # OAuth paths
  match 'oauth/facebook/connnect' => 'oauth#facebook_connect', :as => 'facebook_connect'
  match 'oauth/facebook/return' => 'oauth#facebook_return', :as => 'facebook_return'
  match 'oauth/facebook/associate' => 'oauth#associate_facebook_with_account', :as => 'associate_facebook_with_hoptopus_account'
  match 'oauth/facebook/register' => 'oauth#facebook_register', :as => 'facebook_register'

  # Wiki paths
  match 'wiki/:type(/:id)', :controller => 'wiki', :action => 'list'
  
  root :to => "home#index"
  
  # This needs to be a the bottom!!!
  match '*path', :controller => 'application', :action => 'render_404'
end
