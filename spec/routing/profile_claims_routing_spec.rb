require "spec_helper"

describe ProfileClaimsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(get("/profile_claims")).to route_to("profile_claims#index")
    end

    it "routes to #new" do
      expect(get("/profile_claims/new")).to route_to("profile_claims#new")
    end

    it "routes to #show" do
      expect(get("/profile_claims/1")).to route_to("profile_claims#show", :id => "1")
    end

    it "routes to #edit" do
      expect(get("/profile_claims/1/edit")).to route_to("profile_claims#edit", :id => "1")
    end

    it "routes to #create" do
      expect(post("/profile_claims")).to route_to("profile_claims#create")
    end

    it "routes to #update" do
      expect(put("/profile_claims/1")).to route_to("profile_claims#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(delete("/profile_claims/1")).to route_to("profile_claims#destroy", :id => "1")
    end

  end
end
