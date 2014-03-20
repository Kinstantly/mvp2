class ActiveRecord::Base
	def join_present_attrs(separator=' ', *attrs)
		attrs.map { |attr|
				self.try(attr).presence
			}.compact.join(separator)
	end
	
	def errorfree
		@errorfree ||= begin
			errors.present? && persisted? ? self.class.find(id) : self
		rescue ActiveRecord::RecordNotFound
			self
		end
	end
	
	def lower_case_name
		name.try :downcase
	end
	
	# Return the human name for the attribute if its value is present.
	def human_attribute_name_if_present(attribute)
		send(attribute).present? ? self.class.human_attribute_name(attribute) : nil
	end
	
	# Return an array of human names for any of the attributes whose values are present.
	def human_attribute_names_if_present(*attributes)
		attributes.map do |attribute|
			human_attribute_name_if_present attribute
		end.compact
	end
	
	# The default implementation of the counter_cache option only works for create and destroy.
	# But it needs to also work for update, e.g., when associating a record that was previously created.
	def self.belongs_to(name, options={})
		counter_cache = options.delete :counter_cache
		counter_cache_association = options.delete :counter_cache_association
		reflection = super
		if counter_cache
			belongs_to_name = reflection.name
			belongs_to_foreign_key = reflection.foreign_key
			update_proc = Proc.new { |record| 
				record.send(belongs_to_name).try :update_counter_cache, record, counter_cache: counter_cache, association: counter_cache_association
			}
			after_create update_proc
			after_destroy update_proc
			after_update do |record|
				if (belongs_to_change = record.changes[belongs_to_foreign_key])
					# Update counter cache for the previous parent.
					if (old_belongs_to_id = belongs_to_change[0])
						class_of_belongs_to = record.send(belongs_to_name).try(:class).presence || belongs_to_name.to_s.camelcase.constantize
						class_of_belongs_to.find_by_id(old_belongs_to_id).try :update_counter_cache, record, counter_cache: counter_cache, association: counter_cache_association
					end
					# Now update counter cache for the current parent.
					update_proc.call(record) 
				end
			end
		end
		reflection
	end
	
	# This probably is not necessary.  I think the implementation above of the counter_cache option
	# for belongs_to is good enough.
	# def self.has_many(name, options={}, &extension)
	# 	if (counter_cache = options.delete :counter_cache)
	# 		update_proc = Proc.new { |parent, record|
	# 			parent.update_counter_cache record, counter_cache: counter_cache, association: name
	# 		}
	# 		[:after_add, :after_remove].each do |callback_name|
	# 			options.merge! callback_name => [options.delete(callback_name), update_proc].flatten.compact
	# 		end
	# 	end
	# 	super
	# end

	# This implementation uses the actual count in the database rather than incrementing or decrementing
	# (which can result in data skew).
	def update_counter_cache(record, options={})
		association = options.delete(:association).presence || record.class.table_name
		counter_cache = options.delete :counter_cache
		counter_cache_column = if !counter_cache || counter_cache == true
			"#{record.class.table_name}_count"
		else
			counter_cache
		end
		update_column counter_cache_column, send(association).count
	end
	
	def self.order_by_options
		nil
	end
	
	private
	
	def remove_blanks(strings)
		(strings || []).select(&:present?)
	end
	
	def remove_blanks_and_strip(strings)
		remove_blanks(strings).map &:strip
	end
	
	# Display area code, number, and if present, extension.
	# Display country code if so designated.
	def display_phone_number(value, show_country_code=false)
		phone = Phonie::Phone.parse value.try(:strip)
		phone.try :format, "#{'%c ' if show_country_code}(%a) %f-%l#{', x%x' if phone.try(:extension).present?}"
	end
	
	# Create ID map of associations between the given list of parent records and the records of the specified child association.  Also creates a hash of child ID to child name.  Returns an array with the associations followed by the names.  HTML escapes the names.
	def parent_child_association_info(parents, child_association, map={}, names={})
		parents.each { |parent|
			children = parent.send child_association
			map[parent.id] ||= children.map &:id
			children.each { |child| names[child.id] ||= child.name.html_escape }
		}
		[map, names]
	end
end
