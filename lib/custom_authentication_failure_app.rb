class CustomAuthenticationFailureApp < Devise::FailureApp
	def redirect_url
		#return super unless [:worker, :employer, :user].include?(scope) #make it specific to a scope
		if need_provider_registration?
			provider_sign_up_url
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
	def need_provider_registration?
		attempted_path =~ Regexp.new("^#{claim_user_profile_path('1').chop}")
	end
end
