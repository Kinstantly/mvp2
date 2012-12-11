Mvp2::Application.routes.draw do
	# Home page.
	root :to => 'home#index'
	
	match 'request_expert' => 'home#request_expert'
	match 'become_expert' => 'home#become_expert'
	match 'about' => 'home#about'
	match 'contact' => 'home#contact'
	match 'faq' => 'home#faq'
	match 'terms' => 'home#terms'
	
	# User model on which Devise authentication is based.
	devise_for :users, controllers: { registrations: "users/registrations" }
	
	# Profile is accessed via user.
	# Only current_user should have access to the profile.
	match 'edit_user_profile' => 'users#edit_profile'
	match 'update_user_profile' => 'users#update_profile'
	match 'view_user_profile' => 'users#view_profile'
	# Except admin can see all profiles.
	match 'users' => 'users#index'
	
	resources :profiles
	
	# Links to profiles for search engine crawlers.
	match 'providers' => 'profiles#link_index'
	
	# Where to go after sign-up or sign-in.
	#  Using this option causes the response path to be user_root; kind of weird.
	#  Better to override in the ApplicationController.
	# match 'user_root' => 'users#edit_profile'

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
  # match ':controller(/:action(/:id))(.:format)'
end
