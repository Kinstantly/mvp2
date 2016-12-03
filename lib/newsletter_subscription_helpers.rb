module NewsletterSubscriptionHelpers
	module Methods
		def email_md5_hash(email)
			Digest::MD5.hexdigest email.downcase
		end
	end
	
	def self.included(receiver)
		receiver.extend         Methods # As class methods.
		receiver.send :include, Methods # As instance methods.
	end
end
