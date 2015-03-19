class CustomAuthenticationFailureApp < Devise::FailureApp
	
	include SiteConfigurationHelpers
	
	def i18n_message(default = nil)
		if default
			super
		elsif claiming_profile?
			super(:claiming_profile)
		elsif force_claiming_profile?
			super(:force_claiming_profile)
		elsif reviewing_provider?
			super(:reviewing_provider)
		elsif new_customer?
			super(:new_customer)
		elsif editing_contact_preferences?
			super(:editing_contact_preferences)
		elsif running_as_private_site?
			super(:running_as_private_site)
		else
			super
		end
	end
	
	def redirect_url
		#return super unless [:worker, :employer, :user].include?(scope) #make it specific to a scope
		if reviewing_provider? or new_customer?
			member_sign_up_url
		elsif claiming_profile?
			session[:claiming_profile] = params[:token]
			provider_sign_up_url claim_profile_tracking_parameter
		elsif force_claiming_profile?
			session[:claiming_profile] = params[:token]
			new_user_session_url claim_profile_tracking_parameter
		elsif running_as_private_site?
			alpha_sign_up_url
		else
			super
		end
	end

	# Wiki instructions said you need to override respond to eliminate recall:
	#   https://github.com/plataformatec/devise/wiki/How-To:-Redirect-to-a-specific-page-when-the-user-can-not-be-authenticated
	# But let's try not overriding and see how things work.
	#
	# def respond
	# 	if http_auth?
	# 		http_auth
	# 	else
	# 		redirect
	# 	end
	# end
	
	private
	
	# If attempting to claim a profile, we need to register as a provider first.
	def claiming_profile?
		params[:controller] == 'users' && params[:action] == 'claim_profile'
	end
	
	# If attempting to replace our profile with the profile we want to claim, we need to sign in first.
	def force_claiming_profile?
		params[:controller] == 'users' && params[:action] == 'force_claim_profile'
	end
	
	# If attempting to rate or review a provider, we need to register or sign in first.
	def reviewing_provider?
		(params[:controller] == 'profiles' && params[:action] == 'rate') ||
			(params[:controller] == 'reviews' && ['new', 'create'].include?(params[:action]))
	end
	
	# If we are a new customer, we need to register or sign in as a member.
	def new_customer?
		params[:controller] == 'customers' && ['new', 'create', 'authorize_payment'].include?(params[:action])
	end
	
	# If we want to edit our contact preferences, we need to be logged in.
	def editing_contact_preferences?
		(params[:controller] == 'users' && params[:action] == 'edit_subscriptions') ||
			(params[:controller] == 'users/registrations' && params[:action] == 'edit' && (params[:contact_preferences].present? || params[:subscription_preferences].present?))
	end
end
