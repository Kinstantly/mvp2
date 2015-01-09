class OmniauthCallbacksController < Devise::OmniauthCallbacksController
	
	layout 'popup'
	before_filter :authenticate_user!

	def stripe_connect
		auth = request.env["omniauth.auth"]
		stripe_user_id = auth.try(:[], :uid)
		access_token = auth.try(:[], :credentials).try(:[], :token)
		publishable_key = auth.try(:[], :extra).try(:[], :raw_info).try(:[], :stripe_publishable_key)
		stripe_info = StripeInfo.find_or_initialize_by_user_id(current_user.id)
		stripe_info.stripe_user_id = stripe_user_id
		stripe_info.access_token = access_token
		stripe_info.publishable_key = publishable_key
		if stripe_info.save!
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
