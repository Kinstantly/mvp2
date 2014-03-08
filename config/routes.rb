Mvp2::Application.routes.draw do
	# Home page.
	root :to => 'home#index'
	
	match 'request_expert' => 'home#request_expert'
	match 'become_expert' => 'home#become_expert'
	match 'about' => 'home#about'
	match 'contact' => 'home#contact'
	match 'faq' => 'home#faq'
	match 'terms' => 'home#terms'
	match 'admin' => 'home#admin'
	match 'show_all_categories' => 'home#show_all_categories'
	
	# User model on which Devise authentication is based.
	devise_for :users, controllers: { registrations: 'users/registrations', sessions: 'users/sessions' }
	# Alternate Devise routes for special uses.
	devise_scope :user do
		get '/provider/sign_up', to: 'users/registrations#new', is_provider: true
		get '/member/sign_up', to: 'users/registrations#new', is_provider: false
		get '/member/sign_up_return', to: 'users/registrations#new', is_provider: false, store_referrer: true
		get '/member/awaiting_confirmation', to: 'users/registrations#awaiting_confirmation'
		get '/member/sign_in_return', to: 'devise/sessions#new', store_referrer: true
		get '/alpha/sign_up', to: 'users/registrations#new', is_private_alpha: true
	end
	
	# When profile is accessed via user.
	# Only current_user should have access to the profile.
	match 'edit_user_profile' => 'users#edit_profile'
	match 'update_user_profile' => 'users#update_profile'
	match 'view_user_profile' => 'users#view_profile'
	match 'claim_profile/:token' => 'users#claim_profile', as: :claim_user_profile
	match 'claim_profile/:token/confirm' => 'users#force_claim_profile', as: :force_claim_user_profile
	# Except admin can see all profiles.
	match 'users' => 'users#index'
	
	resources :profiles do
		member do
			get 'new_invitation'
			put 'send_invitation'
			get 'rating_score'
			get 'rate'
			post 'rate'
			put 'formlet_update'
			post 'photo_update'
			# plain layout; legacy
			get 'show_plain'
			get 'edit_plain'
			get 'claim/:token', action: :show_claiming, as: :show_claiming
			get 'services_info'
			get 'show_tab'
			get 'edit_tab'
		end
		collection do
			get :admin
			get 'page/:page', action: :index
			get :autocomplete_service_name
			get :autocomplete_specialty_name
			get :autocomplete_location_city
			get :autocomplete_profile_lead_generator
		end
	end
	
	# Accessing my profile (for providers).
	match 'my_profile' => 'profiles#view_my_profile'
	match 'confirm_claim_profile/:claim_token' => 'profiles#view_my_profile', as: :confirm_claim_profile
	match 'edit_my_profile' => 'profiles#edit_my_profile'
	
	# Links to profiles for search engine crawlers.
	match 'providers' => 'profiles#link_index'
	match 'providers/page/:page' => 'profiles#link_index'
	
	# Profile search.
	match 'search_providers' => 'profiles#search'
	match 'search_providers/service/:service_id' => 'profiles#search', as: :search_providers_by_service
	match 'search_providers/service/:service_id/page/:page' => 'profiles#search'
	
	resources :categories
	
	resources :services do
		get 'find_by_name', on: :collection
	end
	
	resources :specialties do
		collection do
			get :find_by_name
			get :autocomplete_search_term_name
		end
	end
	
	resources :reviews, except: [:new, :index] do
		member do
			put :admin_update
		end
		collection do
			post :admin_create
		end
	end
	get 'review/:profile_id' => 'reviews#new', as: :new_review_for_profile
	post 'review/:profile_id'     => 'reviews#create', as: :save_review_for_profile
	
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
