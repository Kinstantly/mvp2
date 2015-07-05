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
		expect(newsletter.errors_on(:cid).size).to eq 0
		expect(newsletter.errors_on(:list_id).size).to eq 0
		expect(newsletter.errors_on(:title).size).to eq 0
		expect(newsletter.errors_on(:subject).size).to eq 0
		expect(newsletter.errors_on(:archive_url).size).to eq 0
		expect(newsletter.errors_on(:content).size).to eq 0
		expect(newsletter.errors_on(:send_time).size).to eq 0
	end
	
	context "required attributes" do
		it "must have cid" do
			newsletter.cid = nil
			expect(newsletter.errors_on(:cid).size).to eq 1
		end
		it "must have list_id" do
			newsletter.list_id = nil
			expect(newsletter.errors_on(:list_id).size).to eq 1
		end
		it "must have title" do
			newsletter.title = nil
			expect(newsletter.errors_on(:title).size).to eq 1
		end
		it "must have subject" do
			newsletter.subject = nil
			expect(newsletter.errors_on(:subject).size).to eq 1
		end
		it "must have content" do
			newsletter.content = nil
			expect(newsletter.errors_on(:content).size).to eq 1
		end
		it "must have send_time" do
			newsletter.send_time = nil
			expect(newsletter.errors_on(:send_time).size).to eq 1
		end
	end
end
