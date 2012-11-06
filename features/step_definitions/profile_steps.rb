### Utility methods ###

def set_up_new_data
	create_visitor
	@profile_data ||= { first_name: 'Know', middle_name: 'I', last_name: 'Tall',
		office_phone: '415-555-1234', url: 'http://knowitall.com', address1: '123 Main St.' }
	@profile_data_2 ||= { first_name: 'Can', middle_name: 'I', last_name: 'Helpyou',
		office_phone: '800-555-1111', url: 'http://canihelpyou.com', address1: '10 Broadway Blvd.' }
	@unattached_profile_data ||= { first_name: 'Prospect', middle_name: 'A', last_name: 'Expert',
		office_phone: '888-555-5555', url: 'http://UnattachedExpert.com', address1: '1 Fleet Street' }
	@category_data ||= { name: 'Parenting' }
end

def find_user_profile
	refresh_user
	@profile = @user.profile
end

def find_unattached_profile
	@profile = Profile.find_by_url @unattached_profile_data[:url]
end

def create_profile
	set_up_new_data
	create_user unless @user
	@profile = FactoryGirl.create(:profile, @profile_data)
	@user.profile = @profile
	@user.save
	FactoryGirl.create(:category, @category_data)
	FactoryGirl.create(:age_range, name: '0 to 6')
	FactoryGirl.create(:age_range, name: '6 to 12')
end

def create_profile_2
	set_up_new_data
	create_user_2 unless @user_2
	@profile_2 = FactoryGirl.create(:profile, @profile_data_2)
	@user_2.profile = @profile_2
	@user_2.save
end

def create_unattached_profile
	set_up_new_data
	@unattached_profile = FactoryGirl.create(:profile, @unattached_profile_data)
end

### GIVEN ###
Given /^an empty profile right after registration$/ do
	set_up_new_data
	sign_up
end

Given /^I am on my profile edit page$/ do
	set_up_new_data
	visit edit_user_profile_path
end

Given /^I want (my|a) profile$/ do |word|
  create_profile
end

Given /^there are multiple profiles in the system$/ do
	create_profile
	create_profile_2
end

Given /^I have no country code in my profile$/ do
	@user.profile.country = nil
	@user.profile.save
end

Given /^I have a country code of "(.*?)" in my profile$/ do |country|
	@user.profile.country = country
	@user.profile.save
end

Given /^there is an unclaimed profile$/ do
	create_unattached_profile
end

Given /^I visit the edit page for the unclaimed profile$/ do
	create_unattached_profile
	find_unattached_profile
	visit edit_profile_path(@profile)
end

### WHEN ###

When /^I enter new profile information$/ do
	set_up_new_data
	fill_in 'profile_first_name', with: @unattached_profile_data[:first_name]
	fill_in 'profile_middle_name', with: @unattached_profile_data[:middle_name]
	fill_in 'profile_last_name', with: @unattached_profile_data[:last_name]
	fill_in 'Website', with: @unattached_profile_data[:url]
	click_button 'Save'
end

When /^I view my profile$/ do
  visit view_user_profile_path
end

When /^I enter my basic profile information$/ do
	fill_in 'profile_first_name', with: @profile_data[:first_name]
	fill_in 'profile_middle_name', with: @profile_data[:middle_name]
	fill_in 'profile_last_name', with: @profile_data[:last_name]
	click_button 'Save'
	find_user_profile
end

When /^I set my first name to "(.*?)"$/ do |first_name|
	fill_in 'profile_first_name', with: first_name
end

When /^I set my middle name to "(.*?)"$/ do |middle_name|
	fill_in 'profile_middle_name', with: middle_name
end

When /^I set my last name to "(.*?)"$/ do |last_name|
	fill_in 'profile_last_name', with: last_name
end

When /^I set my credentials to "(.*?)"$/ do |credentials|
	fill_in 'profile_credentials', with: credentials
end

When /^I edit my profile information$/ do
	fill_in 'Office', with: @profile_data[:office_phone]
	fill_in 'Website', with: @profile_data[:url]
	click_button 'Save'
	find_user_profile
end

When /^I edit my email address$/ do
	fill_in 'user_email', with: @visitor[:email]
	click_button 'Save'
	find_user_profile
end

When /^Click edit profile$/ do
	click_link 'Edit profile'
end

When /^I click on the cancel link$/ do
	click_link 'Cancel'
end

When /^I save my profile$/ do
	click_button 'Save'
	find_user_profile
end

When /^I check "(.*?)"$/ do |field|
	check field
end

When /^I select the "(.*?)" and "(.*?)" categories$/ do |cat1, cat2|
	within('.categories') do
		check MyHelpers.profile_categories_id(cat1)
		check MyHelpers.profile_categories_id(cat2)
	end
end

# This step uses javascript.
When /^I add the "(.*?)" and "(.*?)" custom categories$/ do |cat1, cat2|
	within('.custom_categories') do
		fill_in MyHelpers.profile_custom_categories_id('1'), with: cat1
		click_button 'add_custom_categories_text_field'
		fill_in MyHelpers.profile_custom_categories_id('2'), with: cat2
	end
end

When /^I select the "(.*?)" category$/ do |category|
	select category, from: 'Category'
end

When /^I select the "(.*?)" age range$/ do |age_range|
	select age_range, from: 'Ages'
end

When /^I visit the profile index page$/ do
	visit profiles_path
end

When /^I visit the new profile page$/ do
	visit new_profile_path
end

When /^I click on the edit link for an unclaimed profile$/ do
	click_link "#{@unattached_profile_data[:first_name]} #{@unattached_profile_data[:middle_name]} #{@unattached_profile_data[:last_name]}"
end

When /^I set the last name to "(.*?)"$/ do |last_name|
	fill_in 'Last name', with: last_name
end

When /^I save the profile$/ do
	click_button 'Save'
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
	current_path.should == view_user_profile_path
end

Then /^I should land on the profile edit page$/ do
	current_path.should == edit_user_profile_path
end

Then /^my basic information should be saved in my profile$/ do
	@profile.first_name.should == @profile_data[:first_name]
	@profile.middle_name.should == @profile_data[:middle_name]
	@profile.last_name.should == @profile_data[:last_name]
end

Then /^my edited information should be saved in my profile$/ do
	@profile.office_phone.should == @profile_data[:office_phone]
	@profile.url.should == @profile_data[:url]
end

Then /^my email address should be saved to my user record$/ do
	@user.email.should == @visitor[:email]
end

Then /^my country code should be set to "(.*?)"$/ do |country|
	@profile.country.should == country
end

Then /^my profile should show "(.*?)"$/ do |value|
	page.should have_content value
end

Then /^my profile should show me as being in the "(.*?)" and "(.*?)" categories$/ do |cat1, cat2|
	within('.categories') do
		page.should have_content cat1
		page.should have_content cat2
	end
end

Then /^my profile should show me as being in the "(.*?)" category$/ do |category|
	within('.category') do
		page.should have_content category
	end
end

Then /^my profile should show the "(.*?)" age range$/ do |age_range|
	within('.age_ranges') do
		page.should have_content age_range
	end
end

Then /^I should see more than one profile$/ do
	page.should have_content @profile_data[:url]
	page.should have_content @profile_data_2[:url]
end

Then /^I should not see profile data$/ do
	page.should_not have_content @profile_data[:url]
end

Then /^I should not see profile data that is not my own$/ do
	page.should_not have_content @profile_data_2[:url]
end

Then /^I should see a new profile form$/ do
	page.should have_content 'Public email'
end

Then /^the new profile should be saved$/ do
	find_unattached_profile
	@profile.first_name.should == @unattached_profile_data[:first_name]
	@profile.middle_name.should == @unattached_profile_data[:middle_name]
	@profile.last_name.should == @unattached_profile_data[:last_name]
	@profile.url.should == @unattached_profile_data[:url]
end

Then /^I should land on the edit page for the unclaimed profile$/ do
	find_unattached_profile
	current_path.should == edit_profile_path(@profile)
end

Then /^the last name in the unclaimed profile should be "(.*?)"$/ do |last_name|
	find_unattached_profile
	@profile.last_name.should == last_name
end

# Dynamic display showing what the display name will be after saving.
Then /^the display name should be dynamically shown as "(.*?)"$/ do |display_name|
	within('.display_name') do
		page.should have_content display_name
	end 
end

# Display name based on various profile fields.
Then /^the display name should be updated to "(.*?)"$/ do |display_name|
	within('.top_nav') do
		page.should have_content display_name
	end 
end
