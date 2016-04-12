require 'spec_helper'

describe AgeRange, :type => :model do
	let(:age_range) { FactoryGirl.build :age_range }
	let(:another_age_range) { FactoryGirl.build :age_range }
	
	it "has a name" do
		expect {
			age_range.name = '0-3'
		}.to change { age_range.name }.from(age_range.name).to('0-3')
	end
	
	it "has a sort index" do
		expect {
			age_range.sort_index = 99
		}.to change { age_range.sort_index }.from(age_range.sort_index).to(99)
	end
	
	it 'can be activated' do
		age_range.active = false
		age_range.save
		expect {
			age_range.active = true
			age_range.save
		}.to change(AgeRange.active, :count).by(1)
	end
	
	it 'can be sorted by index' do
		age_range.sort_index = 99
		age_range.save
		another_age_range.sort_index = 1
		another_age_range.save
		expect(AgeRange.sorted.last).to eq age_range
	end
end
