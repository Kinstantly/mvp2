require 'spec_helper'

describe AdminEvent, :type => :model do
	before(:example) do
		@admin_event = AdminEvent.new
		@admin_event.name = 'something_happened_on_20130531'
	end
	
	it "has a name" do
		expect(@admin_event.save).to be_truthy
	end
end
