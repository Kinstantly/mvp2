class CustomAuthenticationFailureApp < Devise::FailureApp
	def i18n_message(default = nil)
		if default.nil? && claiming_profile?
			super(:claiming_profile)
		else
			super
		end
	end
	
	def redirect_url
		#return super unless [:worker, :employer, :user].include?(scope) #make it specific to a scope
		if claiming_profile?
			claim_your_profile_sign_up_url
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
end
