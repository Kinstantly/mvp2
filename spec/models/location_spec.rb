require 'spec_helper'

describe Location, :type => :model do
	it "has two address fields, city, region, country, postal code, and a note" do
		location = Location.new
		location.address1 = '2 Carrer de Campana'
		location.address2 = 'Suite 65'
		location.city = 'Palma de Mallorca'
		location.region = 'Balearic Islands'
		location.country = 'ES'
		location.postal_code = '070XX'
		location.note = 'The elevator is broken.'
		expect(location).to have(:no).errors_on(:address1)
		expect(location).to have(:no).errors_on(:address2)
		expect(location).to have(:no).errors_on(:city)
		expect(location).to have(:no).errors_on(:region)
		expect(location).to have(:no).errors_on(:country)
		expect(location).to have(:no).errors_on(:postal_code)
		expect(location).to have(:no).errors_on(:note)
	end
	
	it "limits the number of input characters for attributes stored as string or text records" do
		location = Location.new
		[:address1, :address2, :city, :region, :postal_code, :country, :note].each do |attr|
			s = 'a' * Location::MAX_LENGTHS[attr]
			location.send "#{attr}=", s
			expect(location).to have(:no).errors_on(attr)
			location.send "#{attr}=", (s + 'a')
			expect(location).to have(1).error_on(attr)
		end
	end
	
	it "has a search area tag used to limit the scope of full-text searches" do
		location = FactoryGirl.create :location
		location.search_area_tag = FactoryGirl.create :search_area_tag, name: 'East Bay'
		expect(location).to have(:no).errors_on(:search_area_tag)
	end
	
	it "has Sunspot coordinates" do
		lat = 37.7701468
		lon = -122.4451098
		location = Location.new
		location.latitude = lat
		location.longitude = lon
		coords = location.coordinates
		expect(coords.lat).to be_within(0.0000001).of(lat)
		expect(coords.lng).to be_within(0.0000001).of(lon)
	end
	
	context "phone number" do
		before(:each) do
			@location = Location.new
		end
		
		it "should accept a properly formatted US number" do
			@location.phone = '(415) 555-1234'
			expect(@location).to have(:no).errors_on(:phone)
		end
		
		it "should fail with an improperly formatted US number" do
			@location.phone = '(415) 55-1234'
			expect(@location).to have(1).errors_on(:phone)
		end
	end
	
	it "automatically strips leading and trailing whitespace from selected attributes" do
		location = Location.new
		phone = '(800) 555-1001'
		location.phone = " #{phone} "
		expect(location).to have(:no).errors_on(:phone)
		expect(location.phone).to eq phone
	end
end
