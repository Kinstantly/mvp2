# Tip: to view the page, use: save_and_open_page

### Utility methods ###

def set_up_new_data
	create_visitor
	@profile_data ||= { first_name: 'Know', middle_name: 'I', last_name: 'Tall_59284872465',
		primary_phone: '415-555-1234', url: 'http://knowitall.com' }
	@profile_data_2 ||= { first_name: 'Can', middle_name: 'I', last_name: 'Helpyou_57839029577',
		primary_phone: '800-555-1111', url: 'http://canihelpyou.com' }
	@unattached_profile_data ||= { first_name: 'Prospect', middle_name: 'A', last_name: 'Expert_109284920473',
		primary_phone: '888-555-5555', url: 'http://UnattachedExpert.com' }
	@published_profile_data ||= { first_name: 'Sandy', middle_name: 'A', last_name: 'Known_58792040839757',
		primary_phone: '888-555-7777', url: 'http://KnownExpert.com', is_published: true }
	@published_profile_data_2 ||= { first_name: 'Yeti', middle_name: 'B', last_name: 'Foot_6594098385732',
		primary_phone: '888-555-6666', url: 'http://yetibfoot.com', is_published: true }
	@predefined_category = FactoryGirl.create(:predefined_category, name: 'TUTORS') unless @predefined_category
end

def find_user_profile
	refresh_user
	# find_user
	@profile = @user.profile
end

def find_unattached_profile
	@profile = Profile.find_by_url @unattached_profile_data[:url]
end

def find_published_profile
	@profile = Profile.find_by_url @published_profile_data[:url]
end

def create_profile
	set_up_new_data
	create_user unless @user
	@profile = FactoryGirl.create(:profile, @profile_data)
	@user.profile = @profile
	@user.save
	@profile
end

def create_profile_2
	set_up_new_data
	create_user_2 unless @user_2
	@profile_2 = FactoryGirl.create(:profile, @profile_data_2)
	@user_2.profile = @profile_2
	@user_2.save
	@profile_2
end

def create_unattached_profile(override_data={})
	set_up_new_data
	@unattached_profile = FactoryGirl.create(:profile, @unattached_profile_data.merge(override_data))
end

def create_published_profile(override_data={})
	set_up_new_data
	@published_profile = FactoryGirl.create(:profile, @published_profile_data.merge(override_data))
end

def create_published_profile_2
	set_up_new_data
	@published_profile_2 = FactoryGirl.create(:profile, @published_profile_data_2)
end

def formlet_id(name)
	case name
	when 'availability/service area'
		'availability_service_area'
	when 'display name'
		'display_name'
	when 'ages'
		'ages_stages'
	when 'stages'
		'ages_stages'
	when 'insurance'
		'insurance_accepted'
	when 'website'
		'internet'
	when 'categories'
		'services'
	when 'specialties'
		'services'
	when 'consultation methods'
		'contact_options'
	when 'service area'
		'service_area'
	when 'year started'
		'year_started'
	when 'profile photo'
		'profile_photo'
	when 'admin'
		pending 'implement admin formlet'
	else
		name
	end
end

def attribute_display_selector(formlet, which)
	selector = "##{formlet_id formlet}" + case formlet
	when 'services'
		' .attribute_display + .attribute_display'
	when 'specialties'
		' .attribute_display + .attribute_display + .attribute_display'
	else
		' .attribute_display'
	end
	selector += ' + .attribute_display' if which.strip == 'second'
	selector += ' + .attribute_display + .attribute_display' if which.strip == 'third'
	selector
end

def location_address_selector(which)
	selector = 'div.location_block:first-of-type'
	selector = 'div.location_block:first-of-type ~ .location_block' if which.strip == 'second'
	selector
end

### GIVEN ###

Given /^I am on my profile edit page$/ do
	set_up_new_data
	visit edit_my_profile_path
end

Given /^I go to my profile edit page$/ do
	visit edit_my_profile_path
end

Given /^I want (?:my|a|an)(?: unpublished)? profile$/ do
	create_profile
end

Given /^there are multiple(?: users with)?(?: unpublished)? profiles in the system$/ do
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

Given /^I visit the (view|edit|admin view|admin edit) page for (?:a|an|the)( existing)? (claimed|published|unclaimed|unpublished|current) profile( with no locations| with one location| with no reviews| with one review)?$/ do |page, existing, type, items|
	attrs = case items.try(:sub, /\A\s*with\s*/, '')
	when 'no locations'
		{ locations: [] }
	when 'one location'
		{ locations: [FactoryGirl.create(:location)] }
	when 'no reviews'
		{ reviews: [] }
	when 'one review'
		# The review needs a reviewer associated for display purposes, but should not have the
		# associated profile preset because we need to associate it with the profile created here.
		{ reviews: [FactoryGirl.create(:review, reviewer: FactoryGirl.create(:parent))] }
	else
		{}
	end
	
	case type
	when /unclaimed|unpublished/
		create_unattached_profile attrs unless existing
		find_unattached_profile
	when /claimed|published/
		create_published_profile attrs unless existing
		find_published_profile
	end
	
	case page
	when 'view'
		visit profile_path(@profile)
	when 'edit'
		visit edit_profile_path(@profile)
	when 'admin view'
		visit show_plain_profile_path(@profile)
	when 'admin edit'
		visit edit_plain_profile_path(@profile)
	end
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

Given /^a published profile with last name "(.*?)", specialty "(.*?)", and search area tag "(.*?)"$/ do |name, spec, tag|
	create_published_profile
	@published_profile.last_name = name
	@published_profile.specialties = [spec.to_specialty]
	@published_profile.locations = [FactoryGirl.create(:location, search_area_tag: FactoryGirl.create(:search_area_tag, name: tag))]
	@published_profile.save
end

Given /^a published profile with city "(.*?)" and service "(.*?)"$/ do |city, svc|
	create_published_profile
	@published_profile.locations = [FactoryGirl.create(:location, city: city)]
	@published_profile.services << svc.to_service
	@published_profile.save
end

Given /^a published profile with city "(.*?)" and state "(.*?)"$/ do |city, state|
	create_published_profile
	@published_profile.locations = [FactoryGirl.create(:location, city: city, region: state)]
	@published_profile.save
end

Given /^another published profile with city "(.*?)" and state "(.*?)"$/ do |city, state|
	create_published_profile_2
	@published_profile_2.locations = [FactoryGirl.create(:location, city: city, region: state)]
	@published_profile_2.save
end

Given /^(my|a published) profile with cities "(.*?)" and "(.*?)" and states "(.*?)" and "(.*?)"$/ do |which_profile, city1, city2, state1, state2|
	profile = case which_profile
	when 'a published'
		create_published_profile
	else
		create_profile
	end
	profile.locations = [FactoryGirl.create(:location, city: city1, region: state1),
		FactoryGirl.create(:location, city: city2, region: state2)]
	profile.save
end

Given /^a published profile with admin notes "(.*?)"$/ do |notes|
	create_published_profile
	@published_profile.admin_notes = notes
	@published_profile.save
end

Given /^(?:my|the) profile with admin notes "(.*?)"$/ do |notes|
	create_profile
	@profile.admin_notes = notes
	@profile.save
end

Given /^there is a search area tag named "(.*?)"$/ do |tag|
	FactoryGirl.create(:search_area_tag, name: tag)
end

Given /^I have no profile$/ do
	find_user
	@user.profile = nil
	@user.save
end

Given /^I have been invited to claim a profile$/ do
	create_unattached_profile invitation_email: 'asleep@thewheel.wv.us'
	@unattached_profile.invite 'Claim your profile', 'We are inviting you to claim your profile.'
end

Given /^there is a "(.*?)" age range$/ do |age_range|
	FactoryGirl.create :age_range, name: age_range
end

Given /^I have (a|no) profile photo$/ do |photo_present|
	find_user_profile
	case photo_present
	when 'a'
		@profile.profile_photo = Rack::Test::UploadedFile.new(
			Rails.root.join('spec/fixtures/assets/other_profile_photo.jpg'), 'image/png')
	when 'no'
		@profile.profile_photo = nil
	end
	@profile.save
end

### WHEN ###

When /^I view my profile$/ do
  visit my_profile_path
end

# Requires javascript.
When /^I enter( | new | my )profile information$/ do |which|
	profile_data = (which.strip == 'my' ? @profile_data : @unattached_profile_data)
	find('#display_name').click
	within('#display_name') do
		fill_in 'profile_first_name', with: profile_data[:first_name]
		fill_in 'profile_middle_name', with: profile_data[:middle_name]
		fill_in 'profile_last_name', with: profile_data[:last_name]
		click_button 'Save'
	end
	# find('#internet').click
	# within('#internet') do
	# 	fill_in 'Website', with: profile_data[:url]
	# 	click_button 'Save'
	# end
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

When /^(?:I )?click edit my profile$/ do
	click_link 'edit_my_profile_link'
end

When /^I check "(.*?)"$/ do |field|
	check field
end

When /^I select the "(.*?)" category$/ do |cat|
	within('#services .categories') do
		check MyHelpers.profile_categories_id(cat.to_category.id)
	end
end

When /^I select the "(.*?)" and "(.*?)" categories$/ do |cat1, cat2|
	within('#services .categories') do
		check MyHelpers.profile_categories_id(cat1.to_category.id)
		check MyHelpers.profile_categories_id(cat2.to_category.id)
	end
end

When /^I select the "(.*?)" service$/ do |svc|
	within('#services .services') do
		check MyHelpers.profile_services_id(svc.to_service.id)
	end
end

When /^I select the "(.*?)" and "(.*?)" services$/ do |svc1, svc2|
	within('#services .services') do
		check MyHelpers.profile_services_id(svc1.to_service.id)
		check MyHelpers.profile_services_id(svc2.to_service.id)
	end
end

# This step requires javascript.
When /^I add the "(.*?)" and "(.*?)" custom services$/ do |svc1, svc2|
	within('#services .custom_services') do
		click_button 'add_custom_services_text_field'
		fill_in MyHelpers.profile_custom_services_id('1'), with: svc1
		click_button 'add_custom_services_text_field'
		fill_in MyHelpers.profile_custom_services_id('2'), with: svc2
	end
end

# This step requires javascript.
When /^I add the "(.*?)" and "(.*?)" custom services using enter$/ do |svc1, svc2|
	within('#services .custom_services') do
		click_button 'add_custom_services_text_field'
		fill_in MyHelpers.profile_custom_services_id('1'), with: "#{svc1}\r"
		fill_in MyHelpers.profile_custom_services_id('2'), with: svc2
	end
end

# This step requires javascript.
When /^I select the "(.*?)" and "(.*?)" specialties$/ do |spec1, spec2|
	within('#services .specialties') do
		check MyHelpers.profile_specialties_id(spec1.to_specialty.id)
		check MyHelpers.profile_specialties_id(spec2.to_specialty.id)
	end
end

# This step requires javascript.
When /^I add the "(.*?)" and "(.*?)" custom specialties$/ do |spec1, spec2|
	within('#services .custom_specialties') do
		click_button 'add_custom_specialties_text_field'
		fill_in MyHelpers.profile_custom_specialties_id('1'), with: spec1
		click_button 'add_custom_specialties_text_field'
		fill_in MyHelpers.profile_custom_specialties_id('2'), with: spec2
	end
end

# This step requires javascript.
When /^I add the "(.*?)" and "(.*?)" custom specialties using enter$/ do |spec1, spec2|
	within('#services .custom_specialties') do
		click_button 'add_custom_specialties_text_field'
		fill_in MyHelpers.profile_custom_specialties_id('1'), with: "#{spec1}\r"
		fill_in MyHelpers.profile_custom_specialties_id('2'), with: spec2
	end
end

When /^I select "(.*?)" as the search area tag in the "(.*?)" formlet$/ do |tag, formlet|
	within("##{formlet_id formlet} .fields") do
		select tag, from: 'Region for search'
	end
end

When /^I visit the profile index page$/ do
	visit profiles_path
end

When /^I visit the profile link index page$/ do
	visit providers_path
end

When /^I visit the profile admin page$/ do
	set_up_new_data
	visit admin_profiles_path
end

When /^I visit the published profile page$/ do
	visit profile_path(@published_profile)
end

When /^I click on the link for an unclaimed profile$/ do
	click_link "#{@unattached_profile_data[:first_name]} #{@unattached_profile_data[:middle_name]} #{@unattached_profile_data[:last_name]}"
end

When /^I open the "(.*?)" formlet$/ do |formlet|
	find("##{formlet_id formlet}").click
end

When /^I enter "(.*?)" in the "(.*?)" field of the "(.*?)" formlet$/ do |text, field, formlet|
	pending 'editor and admin functions in new design' if ['Admin notes', 'Lead generator'].include? field
	within("##{formlet_id formlet}") do
		fill_in field, with: text
	end
end

When /^I select "(.*?)" as the state in the "(.*?)" formlet$/ do |name, formlet|
	within("##{formlet_id formlet}") do
		select name, from: 'State'
	end
end

When /^I check "(.*?)" in the "(.*?)" formlet$/ do |field, formlet|
	within("##{formlet_id formlet}") do
		check field
	end
end

When /^I click on the "(.*?)" (?:link|button) of the "(.*?)" formlet$/ do |link, formlet|
	within("##{formlet_id formlet}") do
		click_link_or_button link
	end
	sleep 1 # In case this click caused an AJAX call, give it some time to finish to avoid database deadlock with later cleanup phase.
end

When /^I check the publish box in the "(.*?)" formlet$/ do |formlet|
	within("##{formlet_id formlet}") do
		check 'is_published'
	end
end

When /^I save the profile$/ do
	click_button 'save_profile_button'
end

When /^I create the profile$/ do
	click_button 'Create'
end

When /^I click on a user profile link$/ do
	click_link MyHelpers.user_list_profile_link_id(@profile)
end

When /^I click on the profile claim (confirm )?link$/ do |force|
	token = @unattached_profile.invitation_token
	if force.present?
		within('.provider_buttons') do
			click_link 'claim_profile_confirm_link'
		end
	else
		visit claim_user_profile_path(token: token)
	end
end

When /^I invite "(.*?)" to claim the profile$/ do |email|
	click_link 'new_invitation_profile'
	fill_in 'invitation_email', with: email
	click_button 'send_invitation_profile'
end

When /^I preview the invitation to "(.*?)" to claim the profile$/ do |email|
	click_link 'new_invitation_profile'
	fill_in 'invitation_email', with: email
	click_button 'test_invitation_profile'
end

When /^I enter "(.*?)" in the "(.*?)" field of the (first|second) location on my profile edit page$/ do |text, field, which|
	case which
	when 'first'
		within('#locations form .fields') do
			fill_in field, with: text
		end
	when 'second'
		within('#locations form .fields + .fields') do
			fill_in field, with: text
		end
	end
end

When /^I enter "(.*?)" in the "(.*?)" field of the (first|second) location on the admin profile edit page$/ do |text, field, which|
	case which
	when 'first'
		within('.location_contact_profile .fields') do
			fill_in field, with: text
		end
	when 'second'
		within('.location_contact_profile .fields + .fields') do
			fill_in field, with: text
		end
	end
end

When /^I click on the link to see all locations$/ do
	click_link I18n.t 'views.profile.view.more_locations'
end

When /^I (?:should )?see step "(one|two|three)" of "(.*?)" formlet$/ do |step, formlet|
	within("##{formlet_id formlet}") do
		# page.has_css?("li.step_#{step}:not(.aria-hidden)", :visible => true).should be_true
		page.has_css?("li.step_#{step}", :visible => true).should be_true
		case step
		when 'one'
			page.has_no_css?('li.step_two', :visible => true).should be_true
			page.has_no_css?('li.step_three', :visible => true).should be_true
		when 'two'
			page.has_no_css?('li.step_one', :visible => true).should be_true
			page.has_no_css?('li.step_three', :visible => true).should be_true
		when 'three'
			page.has_no_css?('li.step_one.aria-hidden', :visible => true).should be_true
			page.has_no_css?('li.step_two.aria-hidden', :visible => true).should be_true
		end
	end
end

When /^I upload a valid image file "(.*?)"$/ do |file_name|
	within('li.step_one') do
  		attach_file 'standard-attachment', Rails.root.join('spec/fixtures/assets', "#{file_name}").to_s
  	end
end

When /^I import a valid image file from "(.*?)"$/ do |url|
	step 'I click on the "import_from_url_link" link of the "profile photo" formlet'
	step %{I enter "#{url}" in the "source_url" field of the "profile photo" formlet}
	find("li.step_one #import_from_url_button").click
end

When /^I click on the profile photo$/ do
	find('#profile-photo img').click
end

When /^I click on the profile edit tab$/ do
	click_link I18n.t('views.profile.edit.edit_tab')
end

When /^I enter "(.*?)" in the "(.*?)" field$/ do |text, field|
	fill_in field, with: text
end

### THEN ###

Then /^I should see my profile information$/ do
	within('.profile h1') do
		page.should have_content @profile.first_name
		page.should have_content @profile.last_name
	end
end

Then /^meta\-data should contain "(.*?)"$/ do |text|
	page.should have_selector "meta[content~=\"#{text.downcase}\"]"
end

Then /^I should see one of my specialties$/ do
	within('#specialties') do
		page.should have_content @profile.specialties.first.name
	end
end

Then /^I should land on the profile view page$/ do
	current_path.should == my_profile_path
end

Then /^I should (?:land|remain) on the profile edit page$/ do
	current_path.should == edit_my_profile_path
end

Then /^my email address should be saved to my user record$/ do
	@user.email.should == @visitor[:email]
end

Then /^my country code should be set to "(.*?)"$/ do |country|
	find_user_profile
	@profile.locations.each { |location| location.country.should == country}
end

Then /^(?:my|the) profile should show "([^\"]+)"$/ do |value|
	page.should have_content value
end

Then /^(?:my|the) profile should not show "([^\"]+)"$/ do |value|
	page.should_not have_content value
end

Then /^(?:my|the) profile should show "([^\"]+)" within "([^\"]+)"$/ do |value, css_class_name|
	within(".#{css_class_name}") do
		page.should have_content value
	end
end

Then /^(?:my|the) profile should show "([^\"]+)" within the (first|second) location address$/ do |value, which|
	within(location_address_selector which) do
		page.should have_content value
	end
end

Then /^(?:my|the) profile should not show "([^\"]+)" within the (first|second) location address$/ do |value, which|
	within(location_address_selector which) do
		page.all('.location', :visible => true).each do |el|
			el.should_not have_content(value)
		end
	end

end

Then /^my profile should have no locations$/ do
	find_user_profile
	@profile.locations.should have(:no).things
end

Then /^the unclaimed profile should have no locations$/ do
	find_unattached_profile
	@profile.locations.should have(:no).things
end

Then /^the "(.*?)" and "(.*?)" (services|specialties) should appear in the profile edit check list$/ do |name1, name2, type|
	within("#services .#{type}") do
		page.should have_content name1
		page.should have_content name2
	end
end

Then /^then I should be offered the "(.*?)" and "(.*?)" (.*?)$/ do |name1, name2, things|
	within("#services .#{things}") do
		page.should have_content name1
		page.should have_content name2
	end
end

Then /^I should be offered no (.*?)$/ do |things|
	within("#services .#{things}") do
		page.should_not have_content FactoryGirl.attributes_for(things.singularize.to_sym)[:name]
	end
end

Then /^my profile edit page should show "([^\"]+)" displayed( | second | third )(as a link )?in the "([^\"]+)" area$/ do |value, which, link, formlet|
	selector = attribute_display_selector formlet, which
	selector += ' a' if link.present?
	within(selector) do
		page.should have_content value
	end
end

Then /^my profile edit page should show "([^\"]+)" and "([^\"]+)" displayed( | second )in the "([^\"]+)" area$/ do |value1, value2, which, formlet|
	within(attribute_display_selector formlet, which) do
		page.should have_content value1
		page.should have_content value2
	end
end

Then /^I should see more than one profile$/ do
	page.should have_content @profile_data[:last_name]
	page.should have_content @profile_data_2[:last_name]
end

Then /^I should not see profile data$/ do
	page.should_not have_content @profile_data[:last_name]
end

Then /^I should not see profile data that is not my own$/ do
	page.should_not have_content @profile_data_2[:last_name]
end

Then /^I should see published profile data$/ do
	page.should have_content @published_profile_data[:last_name]
end

Then /^I should see (?:a new|an edit) profile form$/ do
	within('.edit.popover .categories') do
		page.should have_content @predefined_category.name
	end
end

Then /^I should see the new profile data$/ do
	page.should have_content @unattached_profile_data[:first_name]
	page.should have_content @unattached_profile_data[:middle_name]
	page.should have_content @unattached_profile_data[:last_name]
	# page.should have_content MyHelpers.strip_url(@unattached_profile_data[:url])
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

Then /^the (?:new|previously unpublished) profile should be published$/ do
	find_unattached_profile
	@profile.is_published.should be_true
end

Then /^the search area tag in the unclaimed profile should be "(.*?)"$/ do |tag|
	find_unattached_profile
	@profile.locations.first.search_area_tag.name.should == tag
end

# Dynamic display showing what the display name will be after saving.
Then /^the display name should be dynamically shown as "(.*?)"$/ do |display_name|
	within('.display_name_area') do
		page.should have_content display_name
	end 
end

Then /^I should see profile data for that user$/ do
	within('span[itemprop="url"]') do
		page.should have_content MyHelpers.strip_url(@profile_data[:url])
	end
end

Then /^I should see "(.*?)" in the page title$/ do |words|
	within('title') do
		page.should have_content words
	end
end

Then /^the profile should be attached to my account$/ do
	find_user_profile
	@profile.should == @unattached_profile
end

Then /^I should see form fields for an extra location on my profile edit page$/ do
	page.should have_css '#locations form .fields + .fields'
end

Then /^I should see form fields for an extra location on the admin profile edit page$/ do
	page.should have_css '.location_contact_profile .fields + .fields'
end

Then /^I should see form fields for a (second )?review on the admin profile edit page$/ do |which|
	page.should have_css ".reviews .fields#{' + .fields' if which.try(:strip) == 'second'}"
end

Then /^I should be asked to replace my existing profile$/ do
	within('a[id="claim_profile_confirm_link"]') do
		page.should have_content 'Click here'
	end
end

Then /^edit my profile page should show "(.*?)" image as my profile photo$/ do |file_name|
	using_wait_time 3 do
		page.has_css?("img[src*='#{file_name}']", :count => 2).should be_true
		file_path = Rails.root.join("public/profile_photos/#{@profile.id}", file_name)
		File.exist?(file_path).should be_true
		File.delete(file_path)
	end
end

Then /^I should see a Google Map$/ do
	within 'body' do
		page.should have_xpath "//script[starts-with(@src, 'https://maps.googleapis.com/maps/api')]"
  	end
  	within('#map_canvas') do
		page.should_not be_blank
	end
end

Then /^I should see "(.*?)" message$/ do |locale_path|
 	page.should have_content I18n.t locale_path
end

Then /^I should see the "(.*?)" formlet$/ do |formlet|
	page.should have_css("##{formlet_id formlet}.formlet", visible: true)
end

Then /^I should see an edit tab$/ do
	page.should have_content I18n.t('views.profile.edit.edit_tab')
end

Then /^the administrator should receive (an|no|\d+) emails?$/ do |amount|
  unread_emails_for(@user.email).size.should == parse_email_count(amount)
end
