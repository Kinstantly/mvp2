class ProviderCustomersController < ApplicationController
	
	respond_to :html
	
	before_filter :authenticate_user!
	
	# Side effect: loads @provider_customers or @provider_customer as appropriate.
	# e.g., for index action, @provider_customers is set to ProviderCustomer.accessible_by(current_ability)
	# For actions specified by the :new option, a new provider_customer will be built rather than fetching one.
	load_and_authorize_resource

	# GET /provider_customers/new
	def new
		respond_with @provider_customer
	end
	
	# POST /provider_customers
	def create
		@provider_customer.create_customer_with_card(
			user:         (user_signed_in? ? current_user : nil),
			profile_id:   params[:profile_id],
			stripe_token: params[:stripeToken],
			amount:       params[:authorization_amount]
		)
		
		respond_with @provider_customer
	end
	
end
