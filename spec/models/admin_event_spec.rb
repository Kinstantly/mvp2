require 'spec_helper'

describe AdminEvent, :type => :model do
	let(:original_name) { 'it_happened_one_morning' }
	let(:new_name) { 'it_happened_one_night' }
	let(:new_admin_event) { FactoryGirl.build :admin_event, name: original_name }
	let(:saved_admin_event) { 
		new_admin_event.save
		new_admin_event
	}
	let(:second_admin_event) { FactoryGirl.create :admin_event, name: "#{original_name}_again" }
	
	it 'has a name' do
		expect {
			new_admin_event.name = new_name
		}.to change { new_admin_event.name }.from(original_name).to(new_name)
	end
	
	it 'can be trashed' do
		saved_admin_event # Create.
		expect {
			saved_admin_event.trash = true
			saved_admin_event.save
		}.to change(AdminEvent, :count).by(-1)
	end
	
	it 'can be ordered by name' do
		saved_admin_event
		second_admin_event
		expect(AdminEvent.order_by_name.last).to eq second_admin_event
	end
end
