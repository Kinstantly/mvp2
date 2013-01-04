require 'spec_helper'

describe Location do
	it "has two address fields, city, region, country, and postal code" do
		location = Location.new
		location.address1 = '2 Carrer de Campana'
		location.address2 = 'Suite 65'
		location.city = 'Palma de Mallorca'
		location.region = 'Balearic Islands'
		location.country = 'ES'
		location.postal_code = '070XX'
		location.should have(:no).errors_on(:address1)
		location.should have(:no).errors_on(:address2)
		location.should have(:no).errors_on(:city)
		location.should have(:no).errors_on(:region)
		location.should have(:no).errors_on(:country)
		location.should have(:no).errors_on(:postal_code)
	end
	
	it "has a search area tag used to limit the scope of full-text searches" do
		location = FactoryGirl.create :location
		location.search_area_tag = FactoryGirl.create :search_area_tag, name: 'East Bay'
		location.should have(:no).errors_on(:search_area_tag)
	end
end
