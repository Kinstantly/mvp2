require 'spec_helper'

describe SearchAreaTag, :type => :model do
	let(:tag) { FactoryGirl.build :search_area_tag }
	
	it "has a name" do
		tag.name = 'South Bay'
		expect(tag.errors_on(:name)).to be_empty
	end
	
	it 'can be ordered for display' do
		search_area_tag_to_display_last = FactoryGirl.create :search_area_tag, display_order: 99
		search_area_tag_to_display_first = FactoryGirl.create :search_area_tag, display_order: 1
		expect(SearchAreaTag.all_ordered.first).to eq search_area_tag_to_display_first
		expect(SearchAreaTag.all_ordered.last).to eq search_area_tag_to_display_last
	end
end
