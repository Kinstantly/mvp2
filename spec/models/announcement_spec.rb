require 'spec_helper'

describe Announcement do
	let(:announcement) { FactoryGirl.create :announcement }
	let(:profile) { FactoryGirl.create :profile }

	it "has these attributes: body, headline, icon, position, button_text, button_url, start_at, end_at" do
		announcement = Announcement.new
		announcement.body = 'Camps fill up quickly, so register early.'
		announcement.headline = 'Register now for Summer Camp!'
		announcement.icon = 0
		announcement.position = 0
		announcement.button_text = 'Register NOW!'
		announcement.button_url = 'http://example.com'
		announcement.start_at = Time.zone.now
		announcement.end_at = Time.zone.now + 1.month
		announcement.should have(:no).errors_on(:body)
		announcement.should have(:no).errors_on(:headline)
		announcement.should have(:no).errors_on(:icon)
		announcement.should have(:no).errors_on(:position)
		announcement.should have(:no).errors_on(:button_text)
		announcement.should have(:no).errors_on(:button_url)
		announcement.should have(:no).errors_on(:start_at)
		announcement.should have(:no).errors_on(:end_at)
	end
	
	it "limits the number of input characters for attributes stored as string or text records" do
		announcement = Announcement.new
		[:headline, :body, :button_text].each do |attr|
			s = 'a' * Announcement::MAX_LENGTHS[attr]
			announcement.send "#{attr}=", s
			announcement.should have(:no).errors_on(attr)
			announcement.send "#{attr}=", (s + 'a')
			announcement.should have(1).error_on(attr)
		end
	end

	it "must be associated with a profile" do
		announcement.profile = nil
		announcement.should have(1).error_on :profile
	end
	
	context "required attributes" do
		it "must have body" do
			announcement.body = nil
			announcement.should have(1).error_on :body
		end
		it "must have headline" do
			announcement.headline = nil
			announcement.should have(1).error_on :headline
		end
		it "must have icon" do
			announcement.icon = nil
			announcement.should have(1).error_on :icon
		end
		it "must have button_text if button_url provided" do
			announcement.button_text = nil
			announcement.should have(1).error_on :button_text
		end
		it "must have button_url if button_text provided" do
			announcement.button_url = nil
			announcement.should have(1).error_on :button_url
		end
		it "button_url and button_text are optional if neither provided" do
			announcement.button_text = nil
			announcement.button_url = nil
			announcement.should have(:no).error_on :button_text
			announcement.should have(:no).error_on :button_url
		end
		it "must have start_at" do
			announcement.start_at = nil
			announcement.should have(1).error_on :start_at
		end
	end

	it "should fail if announcement end date comes before start date" do
		announcement.start_at = Time.zone.now
		announcement.end_at = Time.zone.now - 2.weeks
		announcement.should have(1).errors_on(:end_at)
	end

	it "automatically strips leading and trailing whitespace from selected attributes" do
		announcement = Announcement.new
		[:headline, :body, :button_text].each do |attr|
			s = 'string'
			announcement.send "#{attr}=", "  #{s} "
			announcement.should have(:no).errors_on(attr)
			announcement.send(attr).should == s
		end
	end
	
end

describe ProfileAnnouncement do
	it "has these attributes: search_result_position, search_result_link_text" do
		profile_announcement = ProfileAnnouncement.new
		profile_announcement.search_result_position = 1
		profile_announcement.search_result_link_text = 'Register now for Summer Camp!'
		profile_announcement.should have(:no).errors_on(:search_result_position)
		profile_announcement.should have(:no).errors_on(:search_result_link_text)
	end
	
	it "limits the number of input characters for search_result_link_text" do
		profile_announcement = ProfileAnnouncement.new
		s = 'a' * ProfileAnnouncement::MAX_LENGTHS[:search_result_link_text]
		profile_announcement.search_result_link_text = s
		profile_announcement.should have(:no).errors_on(:search_result_link_text)
		profile_announcement.search_result_link_text = (s + 'a')
		profile_announcement.should have(1).error_on(:search_result_link_text)
	end
	
	it "automatically strips leading and trailing whitespace from selected attributes" do
		profile_announcement = ProfileAnnouncement.new
		s = 'string'
		profile_announcement.search_result_link_text = "  #{s} "
		profile_announcement.should have(:no).errors_on(:search_result_link_text)
		profile_announcement.search_result_link_text.should == s
	end
end

describe PaymentProfileAnnouncement, payments: true do
	let(:payment_profile_announcement) { FactoryGirl.create :payment_profile_announcement }
	
	it "is a type of ProfileAnnouncement" do
		payment_profile_announcement.should be_kind_of ProfileAnnouncement
	end
end
