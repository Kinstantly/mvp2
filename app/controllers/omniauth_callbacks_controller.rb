class OmniauthCallbacksController < Devise::OmniauthCallbacksController
	
	layout :layout
	before_filter :authenticate_user!
	
	before_filter :after_stripe_connect_set_up, only: [:stripe_connect, :failure]

	def stripe_connect
		auth = request.env["omniauth.auth"]
		stripe_info = StripeInfo.find_or_initialize_by_user_id(current_user.id)
		if stripe_info.configure_authorization(auth)
			if stripe_info.fully_enabled?
				render 'success'
			else
				account = stripe_info.stripe_account
				logger.info "Stripe account not fully enabled. email => #{account[:email]}, details_submitted => #{account[:details_submitted]}, transfer_enabled => #{account[:transfer_enabled]}, charge_enabled => #{account[:charge_enabled]}"
				redirect_to stripe_dashboard_url
			end
		else
			logger.error "Stripe Connect error for user #{current_user.id}. stripe_info.errors => #{stripe_info.errors.full_messages}. Omniauth Params => #{auth}"
			render 'error'
		end
	end

	def failure
		if params[:error] == 'access_denied'
			logger.info "Stripe Connect: #{params}"
			render 'access_denied'
			# if @after_stripe_connect_path
			# 	redirect_to @after_stripe_connect_path, notice: 'Stripe Connect cancelled'
			# else
			# 	render 'access_denied'
			# end
		else
			logger.error "Stripe Connect error: #{params}"
			render 'error'
		end
	end
	
	private
	
	def after_stripe_connect_set_up
		@after_stripe_connect_path = session[:after_stripe_connect_path].presence
		# session[:after_stripe_connect_path] = nil
	end
	
	def layout
		@after_stripe_connect_path ? 'interior' : 'popup'
	end
end
