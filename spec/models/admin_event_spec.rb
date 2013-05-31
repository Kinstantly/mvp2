require 'spec_helper'

describe AdminEvent do
	before(:each) do
		@admin_event = AdminEvent.new
		@admin_event.name = 'something_happened_on_20130531'
	end
	
	it "has a name" do
		@admin_event.save.should be_true
	end
end
