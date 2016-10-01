class CountryData
	attr_reader :params, :country, :regions
	
	def initialize(params)
		@params = params
	end
	
	def call
		if (@country = Carmen::Country.coded params[:code])
			# Cache minimal region data.
			regions = @country.subregions.map { |region| [region.code, region.name, region.type] }
			@regions = regions.sort { |a, b| a[1] <=> b[1] }
		else
			@region_option_tags = ''
			@region_label = ''
			@postal_code_label = ''
		end
		successful?
	end
	
	def region_option_tags
		@region_option_tags ||= '<option value="">--</option>' + @regions.map do |region|
			"<option value=\"#{region[0]}\">#{region[1]}</option>"
		end.join
	end
	
	def region_label
		@region_label ||= case @country.code
		when 'US'
			'State'
		when 'GB'
			'Region'
		else
			type_labels = @regions.inject({}) do |counts, region|
				type = region[2]
				if counts[type]
					counts[type] += 1
				else
					counts[type] = 1
				end
				counts
			end.to_a
			type_labels.sort! { |a, b| -(a[1] <=> b[1]) } # Descending sort by frequency.
			type_labels.map! { |type_count| type_count[0].capitalize } # Labels only.
			if type_labels.size > 4
				type_labels[0, 4].join(', ') + ', etc.'
			else
				type_labels.join(', ')
			end
		end
	end
	
	def postal_code_label
		@postal_code_label ||= case @country.code
		when 'US'
			'Zip Code'
		else
			'Postal Code'
		end
	end
	
	def successful?
		@country.present?
	end
end
