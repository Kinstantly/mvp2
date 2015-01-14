class OmniauthCallbacksController < Devise::OmniauthCallbacksController
	
	layout 'popup'
	before_filter :authenticate_user!

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
		logger.error "Stripe Connect error: #{params}"
		render 'error'
	end
end
