require 'spec_helper'

describe "Newsletters" do
	
	describe "request latest sample url" do
		it "redirects" do
			get latest_newsletter_path(:parent_newsletters_stage1)
			response.status.should eq(302)
		end
	end

	describe "request newsletter archive page" do
		it "responds successfully" do
			get newsletter_list_path
			response.status.should eq(200)
		end
	end

	describe "request newsletter abc page" do
		it "responds successfully" do
			get newsletter_path(:abc)
			response.status.should eq(200)
		end
	end
end
