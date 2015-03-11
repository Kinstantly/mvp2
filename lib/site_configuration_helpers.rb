module SiteConfigurationHelpers
	module ClassMethods
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
	end
	
	module InstanceMethods
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
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end
