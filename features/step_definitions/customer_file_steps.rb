# Tip: to view the page, use: save_and_open_page

def create_customer_file(attributes={})
	FactoryGirl.create :customer_file, attributes.merge(provider: @user)
end

def create_customer_file_for_client(attributes)
	client = FactoryGirl.create :client_user, attributes
	customer = FactoryGirl.create :customer_with_card, user: client
	create_customer_file customer: customer
end

### GIVEN ###

Given /^I am logged in as a payable provider$/ do
	create_payable_provider
	sign_in_payable_provider
end

Given /^I have a client$/ do
	create_customer_file
end

Given /^I have a client with username "(.*?)"$/ do |username|
	create_customer_file_for_client username: username
end

Given /^I have a client with email "(.*?)"$/ do |email|
	create_customer_file_for_client email: email
end

Given /^I have a client with authorized amount "(.*?)"$/ do |amount|
	create_customer_file authorized_amount_usd: amount
end

### WHEN ###

When /^I visit the client list page$/ do
	visit '/customer_files'
end

### THEN ###

