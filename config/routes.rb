Mc::Application.routes.draw do

  get "empreses/home"

  get "empreses/admin"

  get "empreses/auth"

  get "assistits/show"
  get "main/index"

  match 'pgcs/new/:id' => 'pgcs#new'
  get 'pgcs/tree'
  get 'pgcs/delete'
  get 'pgcs/getTreeItemCategory'
  resources :pgcs

  get 'comptes/delete'
  resources :comptes

  get 'assentaments/grid'
  get 'assentaments/fillCtcteInput'
  resources :assentaments

  get 'moviments/grid'
  resources :moviments

  match 'assistits/getFacturaDuplicada' => 'assistits#getFacturaDuplicada'
  match 'assistits/getCodiCompte' => 'assistits#getCodiCompte'
  match 'assistits/getAssentament' => 'assistits#getAssentament'
  match 'assistits/getImpost' => 'assistits#getImpost'
  match 'assistits/getPagament' => 'assistits#getPagament'
  match 'assistits/:option' => 'assistits#show'
  match 'assistit/:assistit' => 'assistits#assistit'
  resources :assistits
  resources :menu

  match "signup", :to => "users#new"
  resources :users
  match "login", :to => "sessions#login"
  post 'sessions/login_attempt'
  match "logout", :to => "sessions#logout"
  match "profile", :to => "sessions#profile"
  match "setting", :to => "sessions#setting"

  resources :home

  match 'users/:id/confirm/:code', :to => 'users#confirm'

  root :to => 'home#index'

  #resources :historials
  get 'historials/search'
  match 'consulta/:mnukey', :to => 'historials#consulta'

  match 'comptabilitat/:option' => 'comptabilitat#show'

  match 'getComptes' => 'application#getComptes'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
