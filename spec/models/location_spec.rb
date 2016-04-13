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
		expect(location.errors_on(:address1).size).to eq 0
		expect(location.errors_on(:address2).size).to eq 0
		expect(location.errors_on(:city).size).to eq 0
		expect(location.errors_on(:region).size).to eq 0
		expect(location.errors_on(:country).size).to eq 0
		expect(location.errors_on(:postal_code).size).to eq 0
		expect(location.errors_on(:note).size).to eq 0
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
