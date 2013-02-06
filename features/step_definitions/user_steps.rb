### UTILITY METHODS ###

def create_visitor
  @visitor ||= { :email => "example@example.com",
    :password => "please", :password_confirmation => "please" }
  @visitor_2 ||= { :email => "second_example@example.com",
    :password => "pleaseplease", :password_confirmation => "pleaseplease" }
end

def find_user
  @user ||= User.where(:email => @visitor[:email]).first
end

def refresh_user
  @user = User.where(:email => @visitor[:email]).first
end

def create_unconfirmed_user
  create_visitor
  delete_user
  sign_up
  visit '/users/sign_out'
end

def create_user
  create_visitor
  delete_user
  @user = FactoryGirl.create(:expert_user, email: @visitor[:email])
end

def create_client_user
  create_visitor
  delete_user
  @visitor[:username] = 'username'
  @user = FactoryGirl.create(:client_user, email: @visitor[:email], username: @visitor[:username])
end

def create_admin_user
  create_user
  @user.add_role :admin
  @user.save
end

def create_profile_editor
  create_user
  @user.add_role :profile_editor
  @user.save
end

def create_user_2
	create_visitor
	@user_2 ||= User.where(:email => @visitor_2[:email]).first
	@user_2.destroy unless @user_2.nil?
	@user_2 = FactoryGirl.create(:expert_user, email: @visitor_2[:email])
end

def delete_user
  @user ||= User.where(:email => @visitor[:email]).first
  @user.destroy unless @user.nil?
end

def sign_up(sign_up_path='/provider/sign_up')
  delete_user
  visit sign_up_path
  fill_in "Email", :with => @visitor[:email]
  fill_in "Password", :with => @visitor[:password]
  fill_in "Password confirmation", :with => @visitor[:password_confirmation]
  fill_in "Username", :with => @visitor[:username] if @visitor[:username]
  click_button "Join us!"
  find_user
end

def sign_up_member
  sign_up '/member/sign_up'
end

def sign_in
  visit '/users/sign_in'
  fill_in "Email", :with => @visitor[:email]
  fill_in "Password", :with => @visitor[:password]
  click_button "Login"
end

### GIVEN ###
Given /^I am not logged in$/ do
  visit '/users/sign_out'
end

Given /^I am logged in$/ do
  create_user
  sign_in
end

Given /^I exist as a user$/ do
  create_user
end

Given /^I am logged in as a client user$/ do
  create_client_user
  sign_in
end

Given /^I do not exist as a user$/ do
  create_visitor
  delete_user
end

Given /^I exist as an unconfirmed user$/ do
  create_unconfirmed_user
end

Given /^I am logged in as (an administrator|a profile editor)$/ do |role|
	case role
	when 'an administrator'
		create_admin_user
	when 'a profile editor'
		create_profile_editor
	end
	sign_in
end

Given /^I am on my account edit page$/ do
	visit edit_user_registration_path
end

### WHEN ###
When /^I sign in with valid credentials$/ do
  create_visitor
  sign_in
end

When /^I sign out$/ do
  visit '/users/sign_out'
end

When /^I sign up with valid user data$/ do
  create_visitor
  sign_up
end

When /^I sign up as a non\-expert with valid user data$/ do
  create_visitor
  @visitor = @visitor.merge(:username => "hoffman")
  sign_up_member
end

When /^I sign up as a non\-expert without a username$/ do
  create_visitor
  @visitor = @visitor.merge(:username => "")
  sign_up_member
end

When /^I sign up with email "([^"]*?)"$/ do |email|
  create_visitor
  @visitor = @visitor.merge(:email => email)
  sign_up
end

When /^I sign up with an invalid email$/ do
  create_visitor
  @visitor = @visitor.merge(:email => "notanemail")
  sign_up
end

When /^I sign up without a password confirmation$/ do
  create_visitor
  @visitor = @visitor.merge(:password_confirmation => "")
  sign_up
end

When /^I sign up without a password$/ do
  create_visitor
  @visitor = @visitor.merge(:password => "")
  sign_up
end

When /^I sign up with a mismatched password confirmation$/ do
  create_visitor
  @visitor = @visitor.merge(:password_confirmation => "please123")
  sign_up
end

When /^I return to the site$/ do
  visit '/'
end

When /^I sign in with a wrong email$/ do
  @visitor = @visitor.merge(:email => "wrong@example.com")
  sign_in
end

When /^I sign in with a wrong password$/ do
  @visitor = @visitor.merge(:password => "wrongpass")
  sign_in
end

When /^I edit my account details$/ do
  click_link "Edit account"
  fill_in "Current password", :with => @visitor[:password]
  click_button "Update"
end

When /^I enter a new password(?: of "([^"]*?)")?$/ do |password|
	password ||= 'kjoi4lk3j8nl'
	fill_in 'user_password', with: password
	fill_in 'user_password_confirmation', with: password
	fill_in 'user_current_password', with: @visitor[:password]
end

When /^I enter a new email address(?: of "([^"]*?)")?$/ do |email|
	email ||= "new_#{@visitor[:email]}"
	fill_in 'user_current_password', with: @visitor[:password]
	fill_in 'user_email', with: email
end

When /^I enter a new username(?: of "([^"]*?)")?$/ do |username|
	username ||= "new_#{@visitor[:username]}"
	fill_in 'user_current_password', with: @visitor[:password]
	fill_in 'user_username', with: username
end

When /^I look at the list of users$/ do
  visit '/'
end

When /^I visit the user index page$/ do
	visit users_path
end

When /^I save the account settings$/ do
	click_button 'Save'
end

### THEN ###
Then /^I should be signed in$/ do
  page.should have_content "Logout"
  page.should_not have_content "Login"
end

Then /^I should be signed out$/ do
  page.should have_content "Login"
  page.should_not have_content "Logout"
end

Then /^I see an unconfirmed account message$/ do
  page.should have_content "A message with a confirmation link has been sent to your email address"
end

Then /^I see a confirmed account message$/ do
  page.should have_content "Your account was successfully confirmed"
end

Then /^I see a successful sign in message$/ do
  page.should have_content "Signed in successfully."
end

Then /^I should see a successful sign up message$/ do
  page.should have_content "Welcome! You have signed up successfully."
end

Then /^I should see an invalid email message$/ do
  page.should have_content "Email is invalid"
end

Then /^I should see a missing password message$/ do
  page.should have_content "Password can't be blank"
end

Then /^I should see a missing password confirmation message$/ do
  page.should have_content "Password doesn't match confirmation"
end

Then /^I should see a mismatched password message$/ do
  page.should have_content "Password doesn't match confirmation"
end

Then /^I should see a missing username message$/ do
  page.should have_content "Username can't be blank"
end

Then /^I should see a signed out message$/ do
  page.should have_content "Signed out successfully."
end

Then /^I see an invalid login message$/ do
  page.should have_content "Invalid email or password."
end

Then /^I should see an account edited message$/ do
  page.should have_content "You updated your account successfully."
end

Then /^I should be an expert$/ do
  @user.should be_expert
end

Then /^I should be a client$/ do
  @user.should be_client
end

Then /^I should see more than one user$/ do
	page.should have_content @visitor[:email]
	page.should have_content @visitor_2[:email]
end

Then /^I should not see user data$/ do
	page.should_not have_content @visitor[:email]
end

Then /^I should not see user data that is not my own$/ do
	page.should_not have_content @visitor_2[:email]
end

Then /^I should be on the provider (?:registration|sign[- ]up) page$/ do
	page.current_path.should == provider_sign_up_path
end
