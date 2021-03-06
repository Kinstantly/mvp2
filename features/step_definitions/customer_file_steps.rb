# Tip: to view the page, use: save_and_open_page

def create_customer_file(attributes={})
	FactoryGirl.create :customer_file, attributes.merge(provider: @user)
end

def create_customer_file_for_client(attributes)
	customer_file_attributes = attributes.delete(:customer_file) || {}
	@customer_file_client_attributes = {password: 'a1@2a1@2', password_confirmation: 'a1@2a1@2'}.merge(attributes)
	client = FactoryGirl.create :client_user, customer_file_client_attributes
	customer = FactoryGirl.create :customer_with_card, user: client
	@customer_file_for_client = create_customer_file({customer: customer}.merge(customer_file_attributes))
end

def customer_file_client_attributes
	@customer_file_client_attributes
end

def customer_file_for_client
	@customer_file_for_client
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

Given /^I have a client with each of username "(.*?)",? email "(.*?)",? and authorized amount "(.*?)"$/ do |username, email, amount|
	create_customer_file_for_client username: username, email: email, customer_file: {authorized_amount_usd: amount}
end

### WHEN ###

When /^I visit the client list page$/ do
	visit '/customer_files'
end

When /^I sign in as the charged client$/ do
	sign_in customer_file_client_attributes
end

When /^I visit my payments page$/ do
	visit customer_path customer_file_for_client.customer
end

### THEN ###

