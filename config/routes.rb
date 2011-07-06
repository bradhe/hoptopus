Hoptopus::Application.routes.draw do
  post "alerts/dismiss"

  # This needs to be up here so that it doesn't match the username rule thinger for below.
  match 'cellars/import-failed' => 'cellars#import_failed', :as => 'cellar_upload_failed'

  resources :cellars, :only => [:show], :constraints => { :id => /.*/ } do
    resources :beers do
      collection do
        post :edit
        put :update
        delete :destroy
      end

      resources :tasting_notes, :only => [:create]
    end

    member do
      post :import
    end
  end

  resource :user, :only => :update, :constraints => { :id => /.*/ } do
    get :preferences
    get :send_confirmation, :as => 'send_confirmation'
    get :confirmation_sent, :as => 'confirmation_sent'

    resources :watches, :only => [:create, :destroy]
  end

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

    resource :lobby do
      get :boom
    end

    root :to => 'lobby#index'
  end

  namespace 'utils' do
    get 'states' => 'geography#states'
  end

  # Shortcut URLs
  match 'login' => 'auth#login'
  match 'register' => 'auth#register'
  match 'logout' => 'auth#logout'
  match 'auth/unconfirmed' => 'auth#unconfirmed', :as => 'unconfirmed'

  # Users paths
  match 'user/confirm-email/:confirmation_code' => 'users#confirm_email', :as => 'confirm_email'
  
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

  # Home paths
  match 'tour' => 'home#tour', :as => 'tour'
  match 'dashboard' => 'home#dashboard', :as => 'dashboard'

  # Search path
  match 'search' => 'search#index', :as => 'search'

  root :to => "home#index"

  # This needs to be a the bottom!!!
  match '*path', :controller => 'application', :action => 'render_404'
end
