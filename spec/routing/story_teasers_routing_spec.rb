require "spec_helper"

RSpec.describe StoryTeasersController, :type => :routing do
	describe "routing" do

		it "routes to #index" do
			expect(:get => "/story_teasers").to route_to("story_teasers#index")
		end

		it "routes to #new" do
			expect(:get => "/story_teasers/new").to route_to("story_teasers#new")
		end

		it "routes to #show" do
			expect(:get => "/story_teasers/1").to route_to("story_teasers#show", :id => "1")
		end

		it "routes to #edit" do
			expect(:get => "/story_teasers/1/edit").to route_to("story_teasers#edit", :id => "1")
		end

		it "routes to #create" do
			expect(:post => "/story_teasers").to route_to("story_teasers#create")
		end

		it "routes to #update via PUT" do
			expect(:put => "/story_teasers/1").to route_to("story_teasers#update", :id => "1")
		end

		it "routes to #destroy" do
			expect(:delete => "/story_teasers/1").to route_to("story_teasers#destroy", :id => "1")
		end

	end
end
