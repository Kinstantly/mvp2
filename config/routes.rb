Rails.application.routes.draw do
	# The priority is based upon order of creation: first created -> highest priority.
	# See how all your routes lay out with "rake routes".
	# You can have the root of your site routed with "root"
	
	# Home page.
	root :to => 'home#index'
	
	get 'about' => 'home#about'
	get 'contact' => 'home#contact'
	get 'faq' => 'home#faq'
	get 'terms' => 'home#terms'
	get 'privacy' => 'home#privacy'
	get 'admin' => 'home#admin'
	get 'show_all_categories' => 'home#show_all_categories'
	get 'blog' => 'home#blog'
	get 'pro' => 'home#pro'
	get 'recent_newsletters' => 'home#recent_newsletters'
	get 'newsletter/latest/:name' => 'newsletters#latest', as: :latest_newsletter
	get 'newsletter/list(/:name)' => 'newsletters#list', as: :newsletter_list
	get 'newsletter/:id' => 'newsletters#show',  as: :newsletter
	get 'newsletter' => 'newsletters#new'
	get 'newsletters' => 'newsletters#new'
	get 'newsletters/subscribed' => 'newsletters#subscribed'
	post 'newsletters/subscribe' => 'newsletters#subscribe'
	get 'oldnewsletters' => 'newsletters#new', oldnewsletters: true
	get 'kidnote' => 'newsletters#new', alerts: true
	get 'kidnotes' => 'newsletters#new', alerts: true, as: :alerts
	get 'kidnotes/subscribed' => 'newsletters#subscribed', alerts: true, as: :alerts_subscribed
	post 'kidnotes/subscribe' => 'newsletters#subscribe', alerts: true, as: :alerts_subscribe
	
	# User model on which Devise authentication is based.
	devise_for :users, controllers: { 
		registrations: 'users/registrations', 
		sessions: 'users/sessions', 
		confirmations: 'users/confirmations',
		two_factor_authentication: 'users/two_factor_authentication',
		omniauth_callbacks: 'omniauth_callbacks'
	}
	
	# Alternate Devise routes for special uses.
	devise_scope :user do
		get '/provider/sign_up', to: 'users/registrations#new', is_provider: true
		get '/member/sign_up', to: 'users/registrations#new', is_provider: false
		get '/member/sign_up_return', to: 'users/registrations#new', is_provider: false, store_referrer: true
		get '/member/awaiting_confirmation', to: 'users/registrations#awaiting_confirmation'
		get '/member/sign_in_return', to: 'devise/sessions#new', store_referrer: true
		get '/alpha/sign_up', to: 'users/registrations#new', is_private_alpha: true
		get '/newsletter', to: 'users/registrations#new', nlsub: 't', as: :newsletter_signup
		get '/newsletters', to: 'users/registrations#new', nlsub: 't'
		get '/in_blog/sign_up', to: 'users/registrations#new', blog: true, nlsub: true, in_blog: true
		get '/in_blog/awaiting_confirmation', to: 'users/registrations#in_blog_awaiting_confirmation', in_blog: true
		get '/in_blog/edit_subscriptions', to: 'users/registrations#in_blog_edit_subscriptions', in_blog: true
		# get '/users/subscriptions/edit', to: 'users/registrations#edit', as: 'edit_subscriptions', subscription_preferences: true
		get 'two_factor_authentication/qrcode', to: 'users/two_factor_authentication#qrcode'
		get 'two_factor_authentication/reset_code', to: 'users/two_factor_authentication#reset_code'
	end
	
	# User can edit their subscriptions without entering their password, i.e., bypass Devise.
	get 'edit_subscriptions' => 'users#edit_subscriptions', as: 'edit_subscriptions'
	patch 'update_subscriptions' => 'users#update_subscriptions'
	
	# DEPRECATED: When profile is accessed via user.
	# match 'edit_user_profile' => 'users#edit_profile'
	# match 'update_user_profile' => 'users#update_profile'
	# match 'view_user_profile' => 'users#view_profile'
	
	# A provider claims their profile via the users controller.
	# But has no other access to their profile via the users controller.
	get 'claim_profile/:token' => 'users#claim_profile', as: :claim_user_profile
	get 'claim_profile/:token/confirm' => 'users#force_claim_profile', as: :force_claim_user_profile
	
	# Admin can list and view user accounts.
	# User can update profile_help attribute.
	resources :users, only: [:index, :show] do
		member do
			patch 'update_profile_help'
		end
	end
	
	resources :profiles do
		member do
			get 'new_invitation'
			patch 'send_invitation'
			get 'rating_score'
			get 'edit_rating'
			get 'rate'
			post 'rate'
			patch 'formlet_update'
			post 'photo_update'
			# plain layout; legacy
			get 'show_plain'
			get 'edit_plain'
			get 'claim/:token', action: :show_claiming, as: :show_claiming
			get 'services_info'
			get 'show_tab'
			get 'edit_tab'
			get 'about_payments'
		end
		collection do
			get :admin
			get 'page/:page', action: :index
			get :autocomplete_service_name
			get :autocomplete_specialty_name
			get :autocomplete_location_city
			get :autocomplete_profile_lead_generator
			get :no_categories
			get :no_subcategories
			get :no_services
		end
	end
	
	# Accessing my profile (for providers).
	get 'my_profile' => 'profiles#view_my_profile'
	get 'confirm_claim_profile/:claim_token' => 'profiles#view_my_profile', as: :confirm_claim_profile
	get 'edit_my_profile' => 'profiles#edit_my_profile'
	
	# Links to profiles for search engine crawlers.
	get 'providers' => 'profiles#link_index'
	get 'providers/page/:page' => 'profiles#link_index'
	
	# Profile search.
	get 'search_providers' => 'profiles#search'
	get 'search_providers/service/:service_id' => 'profiles#search', as: :search_providers_by_service
	get 'search_providers/service/:service_id/page/:page' => 'profiles#search'
	
	resources :categories, except: :show do
		member do
			patch :add_subcategory
			patch :update_subcategory
			patch :remove_subcategory
		end
		collection do
			get :autocomplete_subcategory_name
		end
	end
	
	resources :subcategories, except: :show do
		member do
			patch :add_service
			patch :update_service
			patch :remove_service
		end
		collection do
			get :find_by_name
			get :autocomplete_service_name
		end
	end
	
	resources :services, except: :show do
		get :find_by_name, on: :collection
	end
	
	resources :specialties, except: :show do
		collection do
			get :find_by_name
			get :autocomplete_search_term_name
		end
	end
	
	resources :reviews, except: [:new, :index] do
		member do
			patch :admin_update
		end
		collection do
			post :admin_create
		end
	end
	get 'review/:profile_id' => 'reviews#new', as: :new_review_for_profile
	post 'review/:profile_id'     => 'reviews#create', as: :save_review_for_profile
	
	resources :provider_suggestions

	resources :profile_claims
	get 'profile_claim/:profile_id' => 'profile_claims#new', as: :new_claim_for_profile
	
	resources :contact_blockers
	get 'noemail/:email_delivery_token' => 'contact_blockers#new_from_email_delivery', as: :new_contact_blocker_from_email_delivery
	post 'noemail/:email_delivery_token' => 'contact_blockers#create_from_email_delivery', as: :create_contact_blocker_from_email_delivery
	get 'noemailerror' => 'contact_blockers#email_delivery_not_found', as: :email_delivery_not_found
	get 'noemailconfirmation' => 'contact_blockers#contact_blocker_confirmation', as: :contact_blocker_confirmation
	get 'optout' => 'contact_blockers#new_from_email_address', as: :new_contact_blocker_from_email_address
	post 'optout' => 'contact_blockers#create_from_email_address', as: :create_contact_blocker_from_email_address
	patch 'optout' => 'contact_blockers#create_from_email_address'
	
	# Stripe web hooks
	post 'magenta/:provider_id' => 'stripe#webhook'
	mount StripeEvent::Engine => '/cyan'

	# MailChimp webhook
	# Their validator uses GET, so allow both POST and GET.  Yuck.
	match 'hooks/a11d83adba52b483798f5e7de90c3e57' => 'mailchimp_webhook#process_notification', via: [:get, :post]

	# Customers of a provider.
	resources :customers
	get 'authorize_payment/:profile_id' => 'customers#authorize_payment', as: :authorize_payment
	get 'authorize_payment_confirmation/:profile_id' => 'customers#authorize_payment_confirmation', as: :authorize_payment_confirmation
	resources :customer_files, only: [:index, :show] do
		member do
			get :new_charge
			patch :create_charge
		end
	end
	
	# Charges made to a customer by a provider.
	resources :stripe_charges, only: :show do
		member do
			patch :create_refund
			get :show_to_client
		end
	end
	
	# Displayed teasers that click through to stories.
	resources :story_teasers
	
	# Email delivery events.  Used to track email deliveries.
	# Can be associated with contact_blockers to prevent future deliveries to the specified email address.
	resources :email_deliveries do
		collection do
			get :new_list
			post :create_list
		end
	end
	
	# Catch all other routing requests and do something benign.
	# The main purpose of this route is to provide as little information as possible to site probers.
	# For Rails 4, add "via: :all".
	match '*undefined_path' => 'application#not_found', via: :all
	
	# Where to go after sign-up or sign-in.
	#  Using this option causes the response path to be user_root; kind of weird.
	#  Better to override in the ApplicationController.
	# get 'user_root' => 'users#edit_profile'

  # The priority is based upon order of creation:
  # first created -> highest priority.

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

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root to: 'welcome#index'
end
