### Utility methods ###

def set_up_new_data
	create_visitor
	@profile_data ||= { first_name: 'Know', middle_initial: 'I', last_name: 'Tall',
		office_phone: '415-555-1234', url: 'http://knowitall.com', address1: '123 Main St.' }
end

def find_profile
	refresh_user
	@profile = @user.profile
end

def create_profile
	set_up_new_data
	create_user unless @user
	@profile = FactoryGirl.create(:profile, @profile_data)
	@user.profile = @profile
	@user.save
end

### GIVEN ###
Given /^an empty profile right after registration$/ do
	set_up_new_data
	sign_up
end

Given /^I am on my profile edit page$/ do
	set_up_new_data
	visit edit_profile_path
end

Given /^I want my profile$/ do
  create_profile
end

### WHEN ###

When /^I view my profile$/ do
  visit view_profile_path
end

When /^I enter my basic profile information$/ do
	fill_in 'First name', with: @profile_data[:first_name]
	fill_in 'Middle initial', with: @profile_data[:middle_initial]
	fill_in 'Last name', with: @profile_data[:last_name]
	click_button 'Save'
	find_profile
end

When /^I edit my profile information$/ do
	fill_in 'Office', with: @profile_data[:office_phone]
	fill_in 'Website', with: @profile_data[:url]
	click_button 'Save'
	find_profile
end

When /^I edit my email address$/ do
	fill_in 'Email', with: @visitor[:email]
	click_button 'Save'
	find_profile
end

When /^Click edit profile$/ do
	click_link 'Edit profile'
end

When /^I click on the cancel link$/ do
	click_link 'Cancel'
end

### THEN ###

Then /^I should see my profile information$/ do
	page.should have_content @profile.first_name
	page.should have_content @profile.last_name
end

Then /^I should see my profile address$/ do
	page.should have_content @profile.address1
end

Then /^I should land on the profile view page$/ do
	current_path.should == view_profile_path
end

Then /^I should land on the profile edit page$/ do
	current_path.should == edit_profile_path
end

Then /^my basic information should be saved in my profile$/ do
	@profile.first_name.should == @profile_data[:first_name]
	@profile.middle_initial.should == @profile_data[:middle_initial]
	@profile.last_name.should == @profile_data[:last_name]
end

Then /^my edited information should be saved in my profile$/ do
	@profile.office_phone.should == @profile_data[:office_phone]
	@profile.url.should == @profile_data[:url]
end

Then /^my email address should be saved to my user record$/ do
  @user.email.should == @visitor[:email]
end
