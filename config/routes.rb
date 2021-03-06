KodeKonkurrenz::Application.routes.draw do
  # get "users/show"
  # This line mounts Forem's routes at /forums by default.
  # This means, any requests to the /forums URL of your application will go to Forem::ForumsController#index.
  # If you would like to change where this extension is mounted, simply change the :at option to something different.
  #
  # We ask that you don't use the :as option here, as Forem relies on it being the default of "forem"
  mount Forem::Engine, :at => '/discuss'


  # This line mounts Forem's routes at /forums by default.
  # This means, any requests to the /forums URL of your application will go to Forem::ForumsController#index.
  # If you would like to change where this extension is mounted, simply change the :at option to something different.
  #
  # We ask that you don't use the :as option here, as Forem relies on it being the default of "forem"

  devise_for :users
  # get "pages/home"
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # 
  root to: "pages#home"
  match '/liveGraph', to: 'pages#liveGraph', via: 'get'
  match '/about' , to: 'pages#about', via: 'get'
  match '/contactUs' , to: 'pages#contactUs', via: 'get'
  match '/privacy' , to: 'pages#privacy', via: 'get'
  match '/discuss' , to: 'pages#discuss', via: 'get'
  match '/problems/practice' , to: 'problems#practice', via: 'get'
  match '/security' , to: 'pages#security', via: 'get'
  match '/termsOfService' , to: 'pages#termsOfService', via: 'get'
  match '/admin', to: 'pages#admin', via: 'get'
  match '/users/:id' => 'users#show', via: 'get', as: :user
  match '/users/edit/:id', to: 'users#edit', via: 'get', as: :edit_user
  match '/users/:id', to: 'users#update', via: 'put' # put req'd for bip


  scope '/games' do
    match '/open', to: 'games#open_games', via: 'get'
    match '/join', to: 'games#join', via: 'post'
    match '/create', to: 'games#create_game', via: 'post'
    match '/create/practice', to: 'games#create_game_practice', via: 'post'
    match '/competition/:id', to: 'games#competition', via: 'get', as: 'competition'
    match '/compile', to: 'games#compile', via: 'post'
    match '/execute', to: 'games#execute', via: 'post'
    match '/status/:id', to: 'games#status', via: 'get'
  end

  scope '/admin' do
    resources :problems, :games
  end

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
