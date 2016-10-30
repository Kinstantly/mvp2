require 'spec_helper'
require 'rake'

describe 'kinstantly_locations namespace rake tasks' do
	before(:example) do
		Rake.application.rake_require 'tasks/kinstantly_locations'
		Rake::Task.define_task :environment
	end
	
	describe 'kinstantly_locations:geocode_nils', geocoding_api: true, internet: true do
		let(:summary_1) { 'Swedish dramatic soprano' }
		let(:profile_1) {
			profile = FactoryGirl.create(:published_profile, headline: summary_1)
			profile.locations.create address1: '1398 Haight St', city: 'San Francisco', region: 'CA', postal_code: '94117', country: 'US'
			profile
		}
		
		let(:summary_2) { 'Italian dramatic soprano' }
		let(:profile_2) {
			profile = FactoryGirl.create(:published_profile, headline: summary_2)
			profile.locations.create address1: '1933 Davis Street', city: 'San Leandro', region: 'CA', postal_code: '94577', country: 'US'
			profile
		}
		let(:location_2) {
			profile_2.locations.first
		}
		let(:geocode_2) {
			{ latitude: location_2.latitude, longitude: location_2.longitude }
		}
		
		let(:set_up_profile_index) {
			Profile.clean_index_orphans
			profile_1 and profile_2
			Profile.reindex
			Sunspot.commit
		}
		
		let(:task_name) { 'kinstantly_locations:geocode_nils' }
		let(:run_rake_task) {
			Rake::Task[task_name].reenable
			Rake.application.invoke_task task_name
		}
		
		before(:example) do
			allow(KinstantlyLocationsLog).to receive(:location)
			set_up_profile_index
		end
		
		it 'fixes distance ordering of a profile when its latitude and longitude were indexed with nil values' do
			valid_geocode = geocode_2 # retrieve the valid geocode for the profile
			location_2.update_columns latitude: nil, longitude: nil # set nil geocode without running geocoding callback
			profile_2.reload.index! # reindex with nil geocode
			results = Profile.fuzzy_search(summary_1, order_by_distance: valid_geocode).results
			expect(results.size).to eq 2
			expect(results.first).to eq profile_1
			expect(results.second).to eq profile_2 # profile is last in the results list because of nil geocode
			run_rake_task # now fix the bad geocode and reindex the profile
			results = Profile.fuzzy_search(summary_1, order_by_distance: valid_geocode).results
			expect(results.first).to eq profile_2 # profile is first in the results list with valid geocode
			expect(results.second).to eq profile_1
		end
	end
end
