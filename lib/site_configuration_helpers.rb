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
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end
