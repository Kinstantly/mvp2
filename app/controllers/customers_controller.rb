class CustomersController < ApplicationController
	
	respond_to :html
	
	before_filter :authenticate_user!
	
	# Side effect: loads @customers or @customer as appropriate.
	# e.g., for index action, @customers is set to Customer.accessible_by(current_ability)
	# For actions specified by the :new option, a new customer will be built rather than fetching one.
	load_and_authorize_resource

	# GET /authorize_payment/:profile_id
	def authorize_payment
		@customer = current_user.as_customer || Customer.new
		@profile = @customer.provider_for_profile(params[:profile_id]).profile
		@authorized_amount = @customer.authorized_amount_for_profile params[:profile_id]
		respond_with @customer
	rescue Payment::ChargeAuthorizationError => error
		logger.error "#{self.class} Error: #{error}"
		set_flash_message :alert, :authorize_payment_error
		redirect_to(@customer.new_record? ? edit_user_registration_url : @customer)
	end

	# GET /authorize_payment_confirmation/:profile_id
	def authorize_payment_confirmation
		@customer = current_user.as_customer
		@profile = @customer.provider_for_profile(params[:profile_id]).profile
		@authorized_amount = @customer.authorized_amount_for_profile params[:profile_id]
		respond_with @customer
	rescue Payment::ChargeAuthorizationError => error
		logger.error "#{self.class} Error: #{error}"
		set_flash_message :alert, :authorize_payment_error
	end
	
	# GET /customers/:id
	def show
		@customer_files = @customer.customer_files
	end
	
	# POST /customers
	def create
		success = @customer.save_with_authorization(
			user:         current_user,
			profile_id:   params[:profile_id],
			stripe_token: params[:stripeToken],
			amount:       params[:authorized_amount]
		)
		
		respond_with @customer, location: authorize_payment_confirmation_path(params[:profile_id]) do |format|
			if success
				set_flash_message :notice, :payment_authorized
			else
				format.html { render :authorize_payment }
			end
		end
	end
	
	def update
		@profile = @customer.provider_for_profile(params[:profile_id]).profile
		@authorized_amount = @customer.authorized_amount_for_profile params[:profile_id]
		success = @customer.save_with_authorization(
			profile_id:       params[:profile_id],
			stripe_token:     params[:stripeToken],
			amount:           params[:authorized_amount],
			amount_increment: params[:authorized_amount_increment]
		)
		
		respond_with @customer, location: authorize_payment_confirmation_path(params[:profile_id]) do |format|
			if success
				set_flash_message :notice, :payment_authorized
			else
				format.html { render :authorize_payment }
			end
		end
	end
	
end
