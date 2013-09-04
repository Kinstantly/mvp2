module MailerHelper
	def mailer_image_url(image)
		"#{root_url.chomp('/')}#{path_to_image image}"
	end
	
	def mailer_logo_alt
		"#{t 'company.name'} | #{t 'company.tagline'}"
	end
	
	def mailer_show_profile_to_claim_url(profile)
		if profile.is_published
			show_claiming_profile_url(profile, token: profile.invitation_token)
		else # Provider cannot view it without registering first, so let's just give them the claim URL.
			claim_user_profile_url(token: profile.invitation_token)
		end
	end
end
