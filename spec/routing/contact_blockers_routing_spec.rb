require "spec_helper"

describe ContactBlockersController, :type => :routing do
	describe "routing" do

		it "routes to #new_from_email_delivery" do
			expect(get('/noemail/abcdef')).to route_to("contact_blockers#new_from_email_delivery", email_delivery_token: 'abcdef')
		end

		it "routes to #create_from_email_delivery" do
			expect(post('/noemail/abcdef')).to route_to("contact_blockers#create_from_email_delivery", email_delivery_token: 'abcdef')
		end

		it "routes to #new_from_email_address" do
			expect(get('/optout')).to route_to("contact_blockers#new_from_email_address")
		end

		it "routes to #create_from_email_address" do
			expect(post('/optout')).to route_to("contact_blockers#create_from_email_address")
		end

		it "routes to #create_from_email_address with patch" do
			expect(patch('/optout')).to route_to("contact_blockers#create_from_email_address")
		end

		it "routes to #email_delivery_not_found" do
			expect(get('/noemailerror')).to route_to("contact_blockers#email_delivery_not_found")
		end

		it "routes to #contact_blocker_confirmation" do
			expect(get('/noemailconfirmation')).to route_to("contact_blockers#contact_blocker_confirmation")
		end

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
			expect(patch("/contact_blockers/1")).to route_to("contact_blockers#update", :id => "1")
		end

		it "routes to #destroy" do
			expect(delete("/contact_blockers/1")).to route_to("contact_blockers#destroy", :id => "1")
		end

	end
end
