module LocationsHelper

	# Display the address of the given location composed for a search result.
	# If location is outside the US, append the country name.
	def search_result_address(location)
		return '' unless location
		country_name = location.country == 'US' ? nil : location.display_country
		[location.display_address, country_name].compact.join(', ')
	end

end
