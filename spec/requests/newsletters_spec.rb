require 'spec_helper'

describe "Newsletters" do
	
	describe "request latest sample url" do
		it "responds successfully" do
			get latest_newsletter_path(:parent_newsletters_stage1)
			response.status.should eq(302)
		end
	end
end
