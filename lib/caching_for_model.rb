module CachingForModel
	module ClassMethods
		def predefined_parent_child_info_key(model)
			"#{model.to_s.downcase}_predefined_parent_child_info"
		end
	
		def predefined_parent_child_info(&block)
			Rails.cache.fetch predefined_parent_child_info_key(self), &block
		end
		
		def predefined_info_parent(parent)
			@predefined_info_parent = parent
		end
		
		def predefined_info_models
			[self, @predefined_info_parent].compact
		end
	end
	
	module InstanceMethods
		def expire_predefined_parent_child_info
			self.class.predefined_info_models.each do |model|
				Rails.cache.delete self.class.predefined_parent_child_info_key(model)
			end if is_predefined
		end
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
		receiver.after_save :expire_predefined_parent_child_info
		receiver.after_destroy :expire_predefined_parent_child_info
	end
end
