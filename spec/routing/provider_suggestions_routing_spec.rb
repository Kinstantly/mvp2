require "spec_helper"

describe ProviderSuggestionsController do
	describe "routing" do

		it "routes to #index" do
			get("/provider_suggestions").should route_to("provider_suggestions#index")
		end

		it "routes to #new" do
			get("/provider_suggestions/new").should route_to("provider_suggestions#new")
		end

		it "routes to #show" do
			get("/provider_suggestions/1").should route_to("provider_suggestions#show", :id => "1")
		end

		it "routes to #edit" do
			get("/provider_suggestions/1/edit").should route_to("provider_suggestions#edit", :id => "1")
		end

		it "routes to #create" do
			post("/provider_suggestions").should route_to("provider_suggestions#create")
		end

		it "routes to #update" do
			put("/provider_suggestions/1").should route_to("provider_suggestions#update", :id => "1")
		end

		it "routes to #destroy" do
			delete("/provider_suggestions/1").should route_to("provider_suggestions#destroy", :id => "1")
		end

	end
end
