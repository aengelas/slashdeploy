Rails.application.routes.draw do
  get '/auth/:provider', to: lambda{ |env| [404, {}, ['Not Found']] }, as: :oauth
  get '/auth/jwt/callback' => 'sessions#jwt', as: :jwt_auth
  get '/auth/:provider/callback' => 'sessions#create'
  get '/auth/failure' => 'sessions#failure'

  get '/slack/installed' => 'slack#installed', as: :installed
  get '/slack/install' => 'slack#install', as: :install
  post '/slack/install' => 'slack#early_access', as: :early_access

  get '/login' => redirect('/auth/slack'), as: :login
  post '/logout' => 'sessions#destroy', as: :logout

  # Docs
  get '/docs' => 'documentation#index', as: :documentation

  # For backwards compatibility
  mount SlashDeploy.slack_commands, at: '/commands'

  mount SlashDeploy.slack_commands, at: '/slack/commands'
  mount SlashDeploy.slack_actions, at: '/slack/actions'

  # GitHub
  github_webhooks = Hookshot::Router.build do
    handle :push,              PushEvent
    handle :status,            StatusEvent
    handle :deployment_status, DeploymentStatusEvent
  end
  post '/', to: github_webhooks, constraints: Hookshot.constraint

  root 'pages#index'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
