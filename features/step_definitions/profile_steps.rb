### Utility methods ###

def set_up_new_data
	create_visitor
	@profile_data ||= { first_name: 'Know', middle_initial: 'I', last_name: 'Tall',
		office_phone: '415-555-1234', url: 'http://knowitall.com' }
end

def find_profile
	find_user
	@profile = @user.profile
end

### GIVEN ###
Given /^an empty profile right after registration$/ do
	set_up_new_data
	sign_up
end

When /^I enter my basic profile information$/ do
	fill_in 'First name', with: @profile_data[:first_name]
	fill_in 'Middle initial', with: @profile_data[:middle_initial]
	fill_in 'Last name', with: @profile_data[:last_name]
	click_button 'Save'
	find_profile
end

### THEN ###
Then /^I should land on the profile edit page$/ do
	page.should have_content "First name"
	page.should have_content "Last name"
end

Then /^it should be saved in my profile$/ do
	@profile.first_name.should == @profile_data[:first_name]
	@profile.middle_initial.should == @profile_data[:middle_initial]
	@profile.last_name.should == @profile_data[:last_name]
end
