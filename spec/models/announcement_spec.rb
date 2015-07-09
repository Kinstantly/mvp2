require 'spec_helper'

describe Announcement, :type => :model do
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
		announcement.valid?
		expect(announcement.errors[:body].size).to eq 0
		expect(announcement.errors[:headline].size).to eq 0
		expect(announcement.errors[:icon].size).to eq 0
		expect(announcement.errors[:position].size).to eq 0
		expect(announcement.errors[:button_text].size).to eq 0
		expect(announcement.errors[:button_url].size).to eq 0
		expect(announcement.errors[:start_at].size).to eq 0
		expect(announcement.errors[:end_at].size).to eq 0
	end
	
	it "limits the number of input characters for attributes stored as string or text records" do
		announcement = Announcement.new
		[:headline, :body, :button_text].each do |attr|
			s = 'a' * Announcement::MAX_LENGTHS[attr]
			announcement.send "#{attr}=", s
			announcement.valid?
			expect(announcement.errors[attr].size).to eq 0
			announcement.send "#{attr}=", (s + 'a')
			announcement.valid?
			expect(announcement.errors[attr].size).to eq 1
		end
	end

	it "must be associated with a profile" do
		announcement.profile = nil
		announcement.valid?
		expect(announcement.errors[:profile].size).to eq 1
	end
	
	context "required attributes" do
		it "must have body" do
			announcement.body = nil
			announcement.valid?
			expect(announcement.errors[:body].size).to eq 1
		end
		it "must have headline" do
			announcement.headline = nil
			announcement.valid?
			expect(announcement.errors[:headline].size).to eq 1
		end
		it "must have icon" do
			announcement.icon = nil
			announcement.valid?
			expect(announcement.errors[:icon].size).to eq 1
		end
		it "must have button_text if button_url provided" do
			announcement.button_text = nil
			announcement.valid?
			expect(announcement.errors[:button_text].size).to eq 1
		end
		it "must have button_url if button_text provided" do
			announcement.button_url = nil
			announcement.valid?
			expect(announcement.errors[:button_url].size).to eq 1
		end
		it "button_url and button_text are optional if neither provided" do
			announcement.button_text = nil
			announcement.button_url = nil
			announcement.valid?
			expect(announcement.errors[:button_text].size).to eq 0
			expect(announcement.errors[:button_url].size).to eq 0
		end
		it "must have start_at" do
			announcement.start_at = nil
			announcement.valid?
			expect(announcement.errors[:start_at].size).to eq 1
		end
	end

	it "should fail if announcement end date comes before start date" do
		announcement.start_at = Time.zone.now
		announcement.end_at = Time.zone.now - 2.weeks
		expect(announcement.errors_on(:end_at).size).to eq 1
	end

	it "automatically strips leading and trailing whitespace from selected attributes" do
		announcement = Announcement.new
		[:headline, :body, :button_text].each do |attr|
			s = 'string'
			announcement.send "#{attr}=", "  #{s} "
			announcement.valid?
			expect(announcement.errors[attr].size).to eq 0
			expect(announcement.send(attr)).to eq s
		end
	end
	
end

describe ProfileAnnouncement, :type => :model do
	it "has these attributes: search_result_position, search_result_link_text" do
		profile_announcement = ProfileAnnouncement.new
		profile_announcement.search_result_position = 1
		profile_announcement.search_result_link_text = 'Register now for Summer Camp!'
		profile_announcement.valid?
		expect(profile_announcement.errors[:search_result_position].size).to eq 0
		expect(profile_announcement.errors[:search_result_link_text].size).to eq 0
	end
	
	it "limits the number of input characters for search_result_link_text" do
		profile_announcement = ProfileAnnouncement.new
		s = 'a' * ProfileAnnouncement::MAX_LENGTHS[:search_result_link_text]
		profile_announcement.search_result_link_text = s
		profile_announcement.valid?
		expect(profile_announcement.errors[:search_result_link_text].size).to eq 0
		profile_announcement.search_result_link_text = (s + 'a')
		profile_announcement.valid?
		expect(profile_announcement.errors[:search_result_link_text].size).to eq 1
	end
	
	it "automatically strips leading and trailing whitespace from selected attributes" do
		profile_announcement = ProfileAnnouncement.new
		s = 'string'
		profile_announcement.search_result_link_text = "  #{s} "
		profile_announcement.valid?
		expect(profile_announcement.errors[:search_result_link_text].size).to eq 0
		expect(profile_announcement.search_result_link_text).to eq s
	end
end

describe PaymentProfileAnnouncement, type: :model, payments: true do
	let(:payment_profile_announcement) { FactoryGirl.create :payment_profile_announcement }
	
	it "is a type of ProfileAnnouncement" do
		expect(payment_profile_announcement).to be_kind_of ProfileAnnouncement
	end
end
