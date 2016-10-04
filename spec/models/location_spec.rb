require 'spec_helper'

describe Location, :type => :model do
	let(:intl_location_params) { {
		address1: 'Rúa Virrey Osorio, 30',
		address2: 'Suite 265',
		city: 'A Coruña',
		region: 'GA',
		country: 'ES',
		postal_code: '15011',
		note: 'The elevator is broken.'
	} }
	let(:intl_location) { Location.new(intl_location_params) }
	
	it "has two address fields, city, region, country, postal code, and a note" do
		expect(intl_location.errors_on(:address1).size).to eq 0
		expect(intl_location.errors_on(:address2).size).to eq 0
		expect(intl_location.errors_on(:city).size).to eq 0
		expect(intl_location.errors_on(:region).size).to eq 0
		expect(intl_location.errors_on(:country).size).to eq 0
		expect(intl_location.errors_on(:postal_code).size).to eq 0
		expect(intl_location.errors_on(:note).size).to eq 0
	end
	
	it 'displays the country name' do
		location = Location.new country: 'US'
		expect(location.display_country).to eq 'United States'
	end
	
	it "limits the number of input characters for attributes stored as string or text records" do
		location = Location.new
		[:address1, :address2, :city, :region, :postal_code, :country, :note].each do |attr|
			s = 'a' * Location::MAX_LENGTHS[attr]
			location.send "#{attr}=", s
			expect(location.errors_on(attr).size).to eq 0
			location.send "#{attr}=", (s + 'a')
			expect(location.error_on(attr).size).to eq 1
		end
	end
	
	it "has a search area tag used to limit the scope of full-text searches" do
		location = FactoryGirl.create :location
		location.search_area_tag = FactoryGirl.create :search_area_tag, name: 'East Bay'
		expect(location.errors_on(:search_area_tag).size).to eq 0
	end
	
	context 'geocoding' do
		it 'has a geocodable address' do
			expect(intl_location.geocodable_address).to include intl_location.address1, intl_location.city, intl_location.region, intl_location.postal_code, intl_location.display_country
		end
		
		it 'has no geocodable address if only the country was specified' do
			expect(Location.new(country: 'US').geocodable_address).to eq ''
		end
	end
	
	it "has Sunspot coordinates" do
		lat = 37.7701468
		lon = -122.4451098
		location = Location.new latitude: lat, longitude: lon
		coords = location.coordinates
		expect(coords.lat).to be_within(0.0000001).of(lat)
		expect(coords.lng).to be_within(0.0000001).of(lon)
	end
	
	it 'can be ordered by ID' do
		id1 = (FactoryGirl.create :location).id
		id2 = (FactoryGirl.create :location).id
		expect(Location.order_by_id.first.id).to eq (id1 < id2 ? id1 : id2)
		expect(Location.order_by_id.last.id).to eq (id1 > id2 ? id1 : id2)
	end
	
	context "phone number" do
		let(:location) { FactoryGirl.build :location }
		
		it "should accept a properly formatted US number" do
			location.phone = '(415) 555-1234'
			expect(location.errors_on(:phone).size).to eq 0
		end
		
		it "should fail with an improperly formatted US number" do
			location.phone = '(415) 55-1234'
			expect(location.errors_on(:phone).size).to eq 1
		end
	end
	
	it "automatically strips leading and trailing whitespace from selected attributes" do
		location = FactoryGirl.build :location
		phone = '(800) 555-1001'
		location.phone = " #{phone} "
		expect(location.errors_on(:phone).size).to eq 0
		expect(location.phone).to eq phone
	end
end
