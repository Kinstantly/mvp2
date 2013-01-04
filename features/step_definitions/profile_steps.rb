# Tip: to view the page, use: save_and_open_page

### Utility methods ###

def set_up_new_data
	create_visitor
	@profile_data ||= { first_name: 'Know', middle_name: 'I', last_name: 'Tall',
		office_phone: '415-555-1234', url: 'http://knowitall.com' }
	@profile_data_2 ||= { first_name: 'Can', middle_name: 'I', last_name: 'Helpyou',
		office_phone: '800-555-1111', url: 'http://canihelpyou.com' }
	@unattached_profile_data ||= { first_name: 'Prospect', middle_name: 'A', last_name: 'Expert',
		office_phone: '888-555-5555', url: 'http://UnattachedExpert.com' }
	@published_profile_data ||= { first_name: 'Sandy', middle_name: 'A', last_name: 'Known',
		office_phone: '888-555-7777', url: 'http://KnownExpert.com', is_published: true }
	unless @predefined_category
		@predefined_category = 'TUTORS'.to_category
		@predefined_category.is_predefined = true
		@predefined_category.save
	end
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

def create_published_profile
	set_up_new_data
	@published_profile = FactoryGirl.create(:profile, @published_profile_data)
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

Given /^I go to my profile edit page$/ do
	visit edit_user_profile_path
end

Given /^I want (my|a|an)( unpublished)? profile$/ do |word1, word2|
	create_profile
end

Given /^there are multiple( users with)?( unpublished)? profiles in the system$/ do |phrase1, phrase2|
	create_profile
	create_profile_2
end

Given /^I want a published profile|a published profile exists$/ do
	create_published_profile
end

Given /^a user with a profile exists$/ do
	create_profile
end

Given /^I have no country code in my profile$/ do
	location = @user.profile.locations.first
	if location
		location.country = nil
		location.save
	else
		@user.profile.locations.create(country: nil)
	end
end

Given /^I have a country code of "(.*?)" in my profile$/ do |country|
	location = @user.profile.locations.first
	if location
		location.country = country
		location.save
	else
		@user.profile.locations.create(country: country)
	end
end

Given /^I have a category of "(.*?)" in my profile$/ do |category|
	@user.profile.categories = [category.to_category]
	@user.profile.save
end

Given /^I have a category of "(.*?)" in my profile that is associated with the "(.*?)" and "(.*?)" services$/ do |cat, svc1, svc2|
	category = cat.to_category
	category.services = [svc1.to_service, svc2.to_service]
	category.save
	@user.profile.categories = [category]
	@user.profile.save
end

Given /^I have no predefined categories and no services in my profile$/ do
	@user.profile.categories = []
	@user.profile.services = []
	@user.profile.save
end

Given /^I have a service of "(.*?)" in my profile that is associated with the "(.*?)" and "(.*?)" specialties$/ do |svc, spec1, spec2|
	service = svc.to_service
	service.specialties = [spec1.to_specialty, spec2.to_specialty]
	service.save
	@user.profile.services = [service]
	@user.profile.save
end

Given /^I have no predefined services and no specialties in my profile$/ do
	@user.profile.services = []
	@user.profile.specialties = []
	@user.profile.save
end

Given /^the "(.*?)" and "(.*?)" categories are predefined$/ do |cat1, cat2|
	[cat1, cat2].each do |cat|
		category = cat.to_category
		category.is_predefined = true
		category.save
	end
end

Given /^the predefined category of "(.*?)" is associated with the "(.*?)" and "(.*?)" services$/ do |cat, svc1, svc2|
	category = cat.to_category
	category.is_predefined = true
	category.services = [svc1.to_service, svc2.to_service]
	category.save
end

Given /^the "(.*?)" and "(.*?)" services are predefined$/ do |svc1, svc2|
	[svc1, svc2].each do |svc|
		service = svc.to_service
		service.is_predefined = true
		service.save
	end
end

Given /^the predefined service of "(.*?)" is associated with the "(.*?)" and "(.*?)" specialties$/ do |svc, spec1, spec2|
	service = svc.to_service
	service.is_predefined = true
	service.specialties = [spec1.to_specialty, spec2.to_specialty]
	service.save
end

Given /^there is an unclaimed profile$/ do
	create_unattached_profile
end

Given /^I visit the edit page for an (unclaimed|unpublished) profile$/ do |word|
	create_unattached_profile
	find_unattached_profile
	visit edit_profile_path(@profile)
end

Given /^a published profile with last name "(.*?)" and category "(.*?)"$/ do |name, cat|
	create_published_profile
	@published_profile.last_name = name
	@published_profile.categories = [cat.to_category]
	@published_profile.save
end

Given /^a published profile with last name "(.*?)" and specialty "(.*?)"$/ do |name, spec|
	create_published_profile
	@published_profile.last_name = name
	@published_profile.specialties = [spec.to_specialty]
	@published_profile.save
end

Given /^a published profile with city "(.*?)" and service "(.*?)"$/ do |city, svc|
	create_published_profile
	@published_profile.locations = [FactoryGirl.create(:location, city: city)]
	@published_profile.services << svc.to_service
	@published_profile.save
end

Given /^a published profile with city "(.*?)" and postal code "(.*?)"$/ do |city, postal_code|
	create_published_profile
	@published_profile.locations = [FactoryGirl.create(:location, city: city, postal_code: postal_code)]
	@published_profile.save
end

Given /^there is a search area tag named "(.*?)"$/ do |tag|
	FactoryGirl.create(:search_area_tag, name: tag)
end

### WHEN ###

When /^I enter new profile information$/ do
	set_up_new_data
	fill_in 'profile_first_name', with: @unattached_profile_data[:first_name]
	fill_in 'profile_middle_name', with: @unattached_profile_data[:middle_name]
	fill_in 'profile_last_name', with: @unattached_profile_data[:last_name]
	fill_in 'Website', with: @unattached_profile_data[:url]
	within('.categories') do
		choose MyHelpers.profile_categories_id(@predefined_category.id)
	end
	within('.custom_services') do
		fill_in MyHelpers.profile_custom_services_id('1'), with: 'teacher'
	end
	within('.custom_specialties') do
		fill_in MyHelpers.profile_custom_specialties_id('1'), with: 'teaching'
	end
end

When /^I view my profile$/ do
  visit view_user_profile_path
end

When /^I enter my basic profile information$/ do
	set_up_new_data
	fill_in 'profile_first_name', with: @profile_data[:first_name]
	fill_in 'profile_middle_name', with: @profile_data[:middle_name]
	fill_in 'profile_last_name', with: @profile_data[:last_name]
	within('.categories') do
		choose MyHelpers.profile_categories_id(@predefined_category.id)
	end
	within('.custom_services') do
		fill_in MyHelpers.profile_custom_services_id('1'), with: 'teacher'
	end
	within('.custom_specialties') do
		fill_in MyHelpers.profile_custom_specialties_id('1'), with: 'teaching'
	end
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

When /^I select the "(.*?)" category$/ do |cat|
	within('.categories') do
		choose MyHelpers.profile_categories_id(cat.to_category.id)
	end
end

When /^I select the "(.*?)" and "(.*?)" categories$/ do |cat1, cat2|
	within('.categories') do
		choose MyHelpers.profile_categories_id(cat1.to_category.id)
		choose MyHelpers.profile_categories_id(cat2.to_category.id)
	end
end

When /^I select the "(.*?)" service$/ do |svc|
	within('.services') do
		check MyHelpers.profile_services_id(svc.to_service.id)
	end
end

When /^I select the "(.*?)" and "(.*?)" services$/ do |svc1, svc2|
	within('.services') do
		check MyHelpers.profile_services_id(svc1.to_service.id)
		check MyHelpers.profile_services_id(svc2.to_service.id)
	end
end

# This step requires javascript.
When /^I add the "(.*?)" and "(.*?)" custom services$/ do |svc1, svc2|
	within('.custom_services') do
		fill_in MyHelpers.profile_custom_services_id('1'), with: svc1
		click_button 'add_custom_services_text_field'
		fill_in MyHelpers.profile_custom_services_id('2'), with: svc2
	end
end

# This step requires javascript.
When /^I select the "(.*?)" and "(.*?)" specialties$/ do |spec1, spec2|
	within('.specialties') do
		check MyHelpers.profile_specialties_id(spec1.to_specialty.id)
		check MyHelpers.profile_specialties_id(spec2.to_specialty.id)
	end
end

# This step requires javascript.
When /^I add the "(.*?)" and "(.*?)" custom specialties$/ do |spec1, spec2|
	within('.custom_specialties') do
		fill_in MyHelpers.profile_custom_specialties_id('1'), with: spec1
		click_button 'add_custom_specialties_text_field'
		fill_in MyHelpers.profile_custom_specialties_id('2'), with: spec2
	end
end

When /^I select the "(.*?)" age range$/ do |age_range|
	check MyHelpers.profile_age_ranges_id(age_range)
end

When /^I select "(.*?)" as the search area tag$/ do |tag|
	within('.location_contact_profile') do
		select tag, from: 'search_area_tag'
	end
end

When /^I visit the profile index page$/ do
	visit profiles_path
end

When /^I visit the new profile page$/ do
	set_up_new_data
	visit new_profile_path
end

When /^I click on the link for an unclaimed profile$/ do
	click_link "#{@unattached_profile_data[:first_name]} #{@unattached_profile_data[:middle_name]} #{@unattached_profile_data[:last_name]}"
end

When /^I enter "(.*?)" in the "(.*?)" field$/ do |text, field|
	fill_in field, with: text
end

When /^I check the publish box$/ do
	check 'is_published'
end

When /^I save the profile$/ do
	click_button 'Save'
end

When /^I click on a user profile link$/ do
	click_link MyHelpers.user_list_profile_link_id(@profile)
end

### THEN ###

Then /^I should see my profile information$/ do
	within('.view_profile .display_name') do
		page.should have_content @profile.first_name
		page.should have_content @profile.last_name
	end
end

Then /^I should see one of my categories$/ do
	within('.view_profile .categories') do
		page.should have_content @profile.categories.first.name
	end
end

Then /^I should see one of my specialties$/ do
	within('.view_profile .specialties') do
		page.should have_content @profile.specialties.first.name
	end
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
	page.should have_content @profile_data[:office_phone]
	page.should have_content @profile_data[:url]
end

Then /^my email address should be saved to my user record$/ do
	@user.email.should == @visitor[:email]
end

Then /^my country code should be set to "(.*?)"$/ do |country|
	@profile.locations.first.country.should == country
end

Then /^my profile should show "(.*?)"$/ do |value|
	page.should have_content value
end

Then /^my profile should show "(.*?)" in the location area$/ do |value|
	within('.view_profile .location_contact_profile') do
		page.should have_content value
	end
end

Then /^my profile should show me as being in the "(.*?)" (category|service|specialty)$/ do |name, thing|
	within(".view_profile .#{thing.pluralize}") do
		page.should have_content name
	end
end

Then /^my profile should show me as being in the "(.*?)" and "(.*?)" (.*?)$/ do |name1, name2, things|
	within(".view_profile .#{things}") do
		page.should have_content name1
		page.should have_content name2
	end
end

Then /^the "(.*?)" and "(.*?)" services should appear in the profile edit check list$/ do |svc1, svc2|
	within('.edit_profile .services') do
		page.should have_content svc1
		page.should have_content svc2
	end
end

Then /^then I should be offered the "(.*?)" and "(.*?)" (.*?)$/ do |name1, name2, things|
	within(".edit_profile .#{things}") do
		page.should have_content name1
		page.should have_content name2
	end
end

Then /^my profile should show me as having the "(.*?)" and "(.*?)" (.*?)$/ do |name1, name2, things|
	within(".view_profile .#{things}") do
		page.should have_content name1
		page.should have_content name2
	end
end

Then /^I should be offered no (.*?)$/ do |things|
	within(".edit_profile .#{things}") do
		page.should_not have_content FactoryGirl.attributes_for(things.singularize.to_sym)[:name]
	end
end

Then /^my profile should show the "(.*?)" age range$/ do |age_range|
	within('.view_profile .age_ranges') do
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

Then /^I should see published profile data$/ do
	page.should have_content @published_profile_data[:url]
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

Then /^I should land on the view page for the unclaimed profile$/ do
	find_unattached_profile
	current_path.should == profile_path(@profile)
end

Then /^I should land on the edit page for the unclaimed profile$/ do
	find_unattached_profile
	current_path.should == edit_profile_path(@profile)
end

Then /^the last name in the unclaimed profile should be "(.*?)"$/ do |last_name|
	find_unattached_profile
	@profile.last_name.should == last_name
end

Then /^the (new|previously unpublished) profile should be published$/ do |word|
	find_unattached_profile
	@profile.is_published.should be_true
end

Then /^the search area tag in the unclaimed profile should be "(.*?)"$/ do |tag|
	find_unattached_profile
	@profile.locations.first.search_area_tag.name.should == tag
end

# Dynamic display showing what the display name will be after saving.
Then /^the display name should be dynamically shown as "(.*?)"$/ do |display_name|
	within('.edit_profile .display_name') do
		page.should have_content display_name
	end 
end

# Display name based on various profile fields.
Then /^the display name should be updated to "(.*?)"$/ do |display_name|
	within('.top_nav') do
		page.should have_content display_name
	end 
end

Then /^I should see profile data for that user$/ do
	within('.view_profile .url') do
		page.should have_content @profile_data[:url]
	end
end
