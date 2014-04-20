class CustomAuthenticationFailureApp < Devise::FailureApp
	
	include SiteConfigurationHelpers
	
	def i18n_message(default = nil)
		if default
			super
		elsif claiming_profile?
			super(:claiming_profile)
		elsif reviewing_provider?
			super(:reviewing_provider)
		elsif running_as_private_site?
			super(:running_as_private_site)
		else
			super
		end
	end
	
	def redirect_url
		#return super unless [:worker, :employer, :user].include?(scope) #make it specific to a scope
		if reviewing_provider?
			member_sign_up_url
		elsif claiming_profile?
			session[:claiming_profile] = params[:token]
			provider_sign_up_url claim_profile_tracking_parameter
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
		attempted_path && attempted_path.start_with?(claim_user_profile_path('1').chop)
	end
	
	# If attempting to rate a provider, we need to register or sign in first.
	def reviewing_provider?
		(canonical_path = attempted_path.try(:sub, /\d+/, '1')) &&
			(canonical_path.start_with?(rate_profile_path('1')) ||
			 canonical_path.start_with?(new_review_for_profile_path('1')))
	end
end
