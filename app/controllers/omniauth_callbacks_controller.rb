class OmniauthCallbacksController < Devise::OmniauthCallbacksController
	
	layout 'popup'
	before_filter :authenticate_user!

	def stripe_connect
		auth = request.env["omniauth.auth"]
		stripe_info = StripeInfo.find_or_initialize_by_user_id(current_user.id)
		if stripe_info.configure_authorization(auth)
			render 'success'
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
