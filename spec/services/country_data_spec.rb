require 'spec_helper'

describe CountryData do
	let(:country_code) { 'US' }
	let(:country_region_label) { 'State' }
	let(:postal_code_label) { 'Zip Code' }
	let(:country_regions) { Carmen::Country.coded(country_code).subregions }
	let(:country_data_params) { {
		code: country_code
	} }
	let(:country_data) { CountryData.new(country_data_params) }

	let(:country_data_error) {
		CountryData.new(country_data_params.merge code: nil)
	}
	
	context 'with valid parameters' do
		let!(:country_data_call) { country_data.call }
	
		it 'should return success' do
			expect(country_data_call).to be_truthy
		end
	
		it 'should have a success status' do
			expect(country_data).to be_successful
		end
		
		it 'should have an option tag for each region' do
			expect(country_data.region_option_tags).to include(country_regions.first.name, country_regions.second.name, country_regions.third.name)
		end
		
		it 'should have an appropriate label for regions' do
			expect(country_data.region_label).to include(country_region_label)
		end
		
		it 'should have an appropriate postal code label' do
			expect(country_data.postal_code_label).to eq postal_code_label
		end
	end
	
	context 'for Canada' do
		let(:canada_data) { CountryData.new(code: 'CA') }
		let!(:canada_data_call) { canada_data.call }
		
		it 'should have option tags for Canadian regions' do
			expect(canada_data.region_option_tags).to include('British Columbia', 'Ontario', 'Manitoba')
		end
		
		it 'should label regions appropriately for Canada' do
			expect(canada_data.region_label).to include('Province')
		end
		
		it 'should have a postal code label appropriate for Canada' do
			expect(canada_data.postal_code_label).to eq 'Postal Code'
		end
	end
	
	context 'with invalid parameters' do
		let!(:country_data_call_error) { country_data_error.call }
		
		it 'should not return success' do
			expect(country_data_call_error).to be_falsey
		end
	
		it 'should not have a success status' do
			expect(country_data_error).not_to be_successful
		end
	end
end
