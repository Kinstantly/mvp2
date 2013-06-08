module MailerHelper
	def mailer_image_url(image)
		"#{root_url.chomp('/')}#{path_to_image image}"
	end
	
	def mailer_logo_alt
		"#{t 'company_name'} | #{t 'tagline'}"
	end
end
