# Tip: to view the page, use: save_and_open_page

### UTILITY METHODS ###

def create_email_delivery_for(user=@user)
	@user_email_delivery = FactoryGirl.create :email_delivery, recipient: user.email
end

### GIVEN ###

Given /^I have received an email from Kinstantly$/ do
	create_email_delivery_for @user
end

### WHEN ###

When /^I click on the unsubscribe link for the delivered email$/ do
	visit new_contact_blocker_from_email_delivery_path email_delivery_token: @user_email_delivery.token
end
