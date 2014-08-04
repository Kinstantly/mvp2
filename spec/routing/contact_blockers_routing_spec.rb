require "spec_helper"

describe ContactBlockersController do
	describe "routing" do

		it "routes to #index" do
			get("/contact_blockers").should route_to("contact_blockers#index")
		end

		it "routes to #new" do
			get("/contact_blockers/new").should route_to("contact_blockers#new")
		end

		it "routes to #show" do
			get("/contact_blockers/1").should route_to("contact_blockers#show", :id => "1")
		end

		it "routes to #edit" do
			get("/contact_blockers/1/edit").should route_to("contact_blockers#edit", :id => "1")
		end

		it "routes to #create" do
			post("/contact_blockers").should route_to("contact_blockers#create")
		end

		it "routes to #update" do
			put("/contact_blockers/1").should route_to("contact_blockers#update", :id => "1")
		end

		it "routes to #destroy" do
			delete("/contact_blockers/1").should route_to("contact_blockers#destroy", :id => "1")
		end

	end
end
