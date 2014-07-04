module SunspotIndexing
	module ClassMethods
		
	end
	
	module InstanceMethods
		# Queue a background job if so configured.
		# This can be a big job if there are lots of associated profiles.
		def reindex_profiles(record=nil)
			return if new_record? # For a new record, cannot queue a job and there are no profiles to reindex anyway.
			if REINDEX_PROFILES_IN_BACKGROUND
				delay.do_reindex_profiles
			else
				do_reindex_profiles
			end
		end
		
		def do_reindex_profiles
			if is_a? SearchTerm
				specialties.map(&:profiles).flatten.uniq.map(&:index)
			elsif respond_to? :profiles
				profiles.map(&:index)
			end
			Sunspot.commit
		end
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
		receiver.after_update :reindex_profiles, if: '(respond_to?(:name_changed?) and name_changed?) or (respond_to?(:trash_changed?) and trash_changed?)'
		# after_destroy, reindex_profiles does not succesfully remove from search index.  Use trash=true instead.
	end
end
