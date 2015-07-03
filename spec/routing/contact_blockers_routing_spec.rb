require "spec_helper"

describe ContactBlockersController, :type => :routing do
	describe "routing" do

		it "routes to #index" do
			expect(get("/contact_blockers")).to route_to("contact_blockers#index")
		end

		it "routes to #new" do
			expect(get("/contact_blockers/new")).to route_to("contact_blockers#new")
		end

		it "routes to #show" do
			expect(get("/contact_blockers/1")).to route_to("contact_blockers#show", :id => "1")
		end

		it "routes to #edit" do
			expect(get("/contact_blockers/1/edit")).to route_to("contact_blockers#edit", :id => "1")
		end

		it "routes to #create" do
			expect(post("/contact_blockers")).to route_to("contact_blockers#create")
		end

		it "routes to #update" do
			expect(put("/contact_blockers/1")).to route_to("contact_blockers#update", :id => "1")
		end

		it "routes to #destroy" do
			expect(delete("/contact_blockers/1")).to route_to("contact_blockers#destroy", :id => "1")
		end

	end
end
