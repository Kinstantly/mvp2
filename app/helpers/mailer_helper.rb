module MailerHelper
	
	include SiteConfigurationHelpers
	
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

	def mailer_display_time(time_with_zone)
		time_with_zone.localtime.strftime('%a, %b %d, %Y %l:%M %p %Z')
	end
	
	def mailer_user_link(user)
		link_to (running_as_private_site? ? 'Confirm new account' : 'View account'), user_url(user)
	end
end
