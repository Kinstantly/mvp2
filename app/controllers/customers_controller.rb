class CustomersController < ApplicationController
	
	respond_to :html
	
	before_filter :authenticate_user!
	
	# Side effect: loads @customers or @customer as appropriate.
	# e.g., for index action, @customers is set to Customer.accessible_by(current_ability)
	# For actions specified by the :new option, a new customer will be built rather than fetching one.
	load_and_authorize_resource

	# GET /authorize_payment/:profile_id
	def authorize_payment
		@customer = current_user.as_customer.presence || Customer.new
		respond_with @customer
	end
	
	# POST /customers
	def create
		success = @customer.save_with_authorization(
			user:         current_user,
			profile_id:   params[:profile_id],
			stripe_token: params[:stripeToken],
			amount:       params[:authorized_amount]
		)
		
		respond_with @customer do |format|
			if success
				set_flash_message :notice, :payment_authorized
			else
				format.html { render :authorize_payment }
			end
		end
	end
	
	def update
		success = @customer.save_with_authorization(
			profile_id:       params[:profile_id],
			stripe_token:     params[:stripeToken],
			amount_increment: params[:authorized_amount_increment]
		)
		
		respond_with @customer do |format|
			if success
				set_flash_message :notice, :payment_authorized
			else
				format.html { render :authorize_payment }
			end
		end
	end
	
end
