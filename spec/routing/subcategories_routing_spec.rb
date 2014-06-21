require "spec_helper"

describe SubcategoriesController do
	describe "routing" do

		it "routes to #index" do
			get("/subcategories").should route_to("subcategories#index")
		end

		it "routes to #new" do
			get("/subcategories/new").should route_to("subcategories#new")
		end

		it "routes to #edit" do
			get("/subcategories/1/edit").should route_to("subcategories#edit", :id => "1")
		end

		it "routes to #create" do
			post("/subcategories").should route_to("subcategories#create")
		end

		it "routes to #update" do
			put("/subcategories/1").should route_to("subcategories#update", :id => "1")
		end

		it "routes to #destroy" do
			delete("/subcategories/1").should route_to("subcategories#destroy", :id => "1")
		end

		it "routes to #add_service" do
			put("/subcategories/1/add_service").should route_to("subcategories#add_service", :id => "1")
		end

		it "routes to #update_service" do
			put("/subcategories/1/update_service").should route_to("subcategories#update_service", :id => "1")
		end

		it "routes to #remove_service" do
			put("/subcategories/1/remove_service").should route_to("subcategories#remove_service", :id => "1")
		end

	end
end
