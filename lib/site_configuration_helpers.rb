module SiteConfigurationHelpers
	module ClassMethods
		def running_as_private_site?
			Rails.configuration.running_as_private_site
		end
	end
	
	module InstanceMethods
		def running_as_private_site?
			Rails.configuration.running_as_private_site
		end
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end
