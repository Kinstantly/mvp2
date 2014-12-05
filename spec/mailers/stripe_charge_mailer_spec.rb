require "spec_helper"

describe StripeChargeMailer do
	include EmailSpec::Helpers
	include EmailSpec::Matchers
	include Rails.application.routes.url_helpers
	
	context "customer notification email" do
		let(:customer_file) { FactoryGirl.create :customer_file }
		let(:customer_email) { customer_file.customer.user.email }
		let(:provider_profile) { customer_file.provider.profile }
		let(:new_stripe_charge) {
			stripe_charge = customer_file.stripe_card.stripe_charges.build(
				amount:                1000,
				description:           'Five-minute phone consultation',
				statement_description: 'Dame Joan'
			)
			customer_file.stripe_charges << stripe_charge
			stripe_charge
		}
		let(:email) { StripeChargeMailer.notify_customer new_stripe_charge }
		
		it "should be delivered to the customer that was charged" do
			email.should deliver_to customer_email
		end
		
		it "should identify the provider" do
			email.should have_body_text provider_profile.company_otherwise_display_name
		end
		
		it "should show the charge amount" do
			email.should have_body_text display_currency_amount new_stripe_charge.amount_usd
		end
		
		it "should have a link to charge details" do
			email.should have_body_text customer_url customer_file.customer
		end
		
		it "should have a link to the provider's profile" do
			email.should have_body_text profile_url provider_profile
		end
		
		it "should show the card description" do
			email.should have_body_text display_payment_card_summary new_stripe_charge.stripe_card
		end
		
		it "should show the charge description" do
			email.should have_body_text new_stripe_charge.description
		end
		
		it "should show the statement description" do
			email.should have_body_text new_stripe_charge.statement_description
		end
	end
end
