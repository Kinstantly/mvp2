module SiteConfigurationHelpers
	module Methods
		def running_as_private_site?
			Rails.configuration.running_as_private_site
		end
		
		def claim_profile_tracking_parameter
			Rails.configuration.claim_profile_tracking_parameter
		end
		
		def stripe_live_mode?
			Rails.configuration.stripe[:live_mode]
		end
	
		def stripe_dashboard_url
			Rails.configuration.stripe[:dashboard_url]
		end
		
		def cloudfront_domain_name
			Rails.configuration.cloudfront_domain_name
		end
		
		def blog_url
			Rails.configuration.blog_url
		end
		
		def payment_application_fee_percentage
			Rails.configuration.payment[:application_fee_percentage]
		end
		
		def default_host
			Rails.configuration.default_host
		end
		
		def google_analytics_tracking_id
			Rails.configuration.google_analytics_tracking_id
		end
		
		def mailchimp_list_ids
			Rails.configuration.mailing_lists[:mailchimp_list_ids]
		end
		
		def active_mailing_lists
			Rails.configuration.mailing_lists[:active_lists]
		end
		
		def update_mailing_lists_in_background?
			Rails.configuration.mailing_lists[:update_in_background]
		end
		
		def send_mailchimp_welcome?
			Rails.configuration.mailing_lists[:send_mailchimp_welcome]
		end
		
		def input_date_format_string
			Rails.configuration.input_date_format_string
		end
		
		def input_date_regexp_string
			Rails.configuration.input_date_regexp_string
		end
		
		def input_date_regexp
			Regexp.new Rails.configuration.input_date_regexp_string
		end
		
		def iso_date_regexp
			Rails.configuration.iso_date_regexp
		end
	end
	
	def self.included(receiver)
		receiver.extend         Methods # As class methods.
		receiver.send :include, Methods # As instance methods.
	end
end
