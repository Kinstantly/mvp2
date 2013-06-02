module SunspotIndexing
	module ClassMethods
		
	end
	
	module InstanceMethods
		# This is bad because it runs during a request.
		# Better way is to queue a background job (worker).
		def reindex_profiles(record=nil)
			if is_a? SearchTerm
				specialties.map(&:profiles).flatten.map(&:index)
			elsif respond_to? :profiles
				profiles.map(&:index)
			end
		end
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
		receiver.after_update :reindex_profiles, if: 'name_changed? or trash_changed?'
		# after_destroy, reindex_profiles does not succesfully remove from search index.  Use trash=true instead.
	end
end
