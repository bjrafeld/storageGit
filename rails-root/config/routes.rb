DashboardApp::Application.routes.draw do
  resources :jenkins_factory, only: [:index, :new, :create] do
    member do 
      get 'add_job' => 'jenkins_factory#getAddParams'
      post 'add_job' => 'jenkins_factory#addJob'
      get 'info' => 'jenkins_factory#getInfo'
      post 'info' => 'jenkins_factory#update'
      get 'home' => 'jenkins_factory#home'
      get 'updateJob' => 'jenkins_factory#updateJob'
    end
  end

  match 'jenkins_job/:id/index', :via => :get, :to => 'jenkins_job#jobInfo'
  match 'jenkins_build/:id/index', :via => :get, :to => 'jenkins_build#buildInfo'
  match 'jenkins_job/:id/getBuild', :via => :get, :to => 'jenkins_job#getBuildParams'
  match 'jenkins_job/:id/getBuild', :via => :post, :to => 'jenkins_job#getBuild'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root :to => "jenkins_factory#home"

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

  unless Rails.application.config.consider_all_requests_local
    match '*not_found', to: 'errors#error_404'
  end
end
