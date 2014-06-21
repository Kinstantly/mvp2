require 'spec_helper'

describe "Subcategories" do
	describe "GET /subcategories" do
		it "has an index page" do
			get subcategories_path
			response.status.should be(200)
		end
	end
end
