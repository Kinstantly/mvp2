require 'spec_helper'

describe Newsletter, :type => :model do
	let(:newsletter) { FactoryGirl.create :newsletter }

	it "has these attributes: :cid, :list_id, :send_time, :title, :subject, :archive_url, :content" do
		newsletter = Newsletter.new
		newsletter.cid = 'abc'
		newsletter.list_id = '123'
		newsletter.title = 'Parenting News'
		newsletter.subject = 'This Week: best sport events'
		newsletter.archive_url = 'http://example.com'
		newsletter.content = '<html></html>'
		newsletter.send_time = Time.zone.now
		expect(newsletter).to have(:no).errors_on(:cid)
		expect(newsletter).to have(:no).errors_on(:list_id)
		expect(newsletter).to have(:no).errors_on(:title)
		expect(newsletter).to have(:no).errors_on(:subject)
		expect(newsletter).to have(:no).errors_on(:archive_url)
		expect(newsletter).to have(:no).errors_on(:content)
		expect(newsletter).to have(:no).errors_on(:send_time)
	end
	
	context "required attributes" do
		it "must have cid" do
			newsletter.cid = nil
			expect(newsletter).to have(1).error_on :cid
		end
		it "must have list_id" do
			newsletter.list_id = nil
			expect(newsletter).to have(1).error_on :list_id
		end
		it "must have title" do
			newsletter.title = nil
			expect(newsletter).to have(1).error_on :title
		end
		it "must have subject" do
			newsletter.subject = nil
			expect(newsletter).to have(1).error_on :subject
		end
		it "must have content" do
			newsletter.content = nil
			expect(newsletter).to have(1).error_on :content
		end
		it "must have send_time" do
			newsletter.send_time = nil
			expect(newsletter).to have(1).error_on :send_time
		end
	end
end
