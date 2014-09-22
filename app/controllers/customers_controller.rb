class CustomersController < ApplicationController
	
	respond_to :html
	
	before_filter :authenticate_user!
	
	# Side effect: loads @customers or @customer as appropriate.
	# e.g., for index action, @customers is set to Customer.accessible_by(current_ability)
	# For actions specified by the :new option, a new customer will be built rather than fetching one.
	load_and_authorize_resource

	# GET /customers/new
	def new
		respond_with @customer
	end
	
	# POST /customers
	def create
		@customer.save_with_authorization(
			user:         (user_signed_in? ? current_user : nil),
			profile_id:   params[:profile_id],
			stripe_token: params[:stripeToken],
			amount:       params[:authorization_amount]
		)
		
		respond_with @customer
	end
	
end
