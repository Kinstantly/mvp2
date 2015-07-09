require "spec_helper"

describe ProviderSuggestionsController, :type => :routing do
	describe "routing" do

		it "routes to #index" do
			expect(get("/provider_suggestions")).to route_to("provider_suggestions#index")
		end

		it "routes to #new" do
			expect(get("/provider_suggestions/new")).to route_to("provider_suggestions#new")
		end

		it "routes to #show" do
			expect(get("/provider_suggestions/1")).to route_to("provider_suggestions#show", :id => "1")
		end

		it "routes to #edit" do
			expect(get("/provider_suggestions/1/edit")).to route_to("provider_suggestions#edit", :id => "1")
		end

		it "routes to #create" do
			expect(post("/provider_suggestions")).to route_to("provider_suggestions#create")
		end

		it "routes to #update" do
			expect(put("/provider_suggestions/1")).to route_to("provider_suggestions#update", :id => "1")
		end

		it "routes to #destroy" do
			expect(delete("/provider_suggestions/1")).to route_to("provider_suggestions#destroy", :id => "1")
		end

	end
end
