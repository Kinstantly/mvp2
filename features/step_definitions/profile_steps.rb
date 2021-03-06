# Tip: to view the page, use: save_and_open_page

### Utility methods ###

def set_up_new_data
	create_visitor
	@profile_data ||= { first_name: 'Know', middle_name: 'I', last_name: 'Tall_59284872465',
		company_name: 'Co_59284872465', primary_phone: '415-555-1234', url: 'http://knowitall.com' }
	@profile_data_2 ||= { first_name: 'Can', middle_name: 'I', last_name: 'Helpyou_57839029577',
		company_name: 'Co_57839029577', primary_phone: '800-555-1111', url: 'http://canihelpyou.com' }
	@unattached_profile_data ||= { first_name: 'Prospect', middle_name: 'A', last_name: 'Expert_109284920473',
		company_name: 'Co_109284920473', primary_phone: '888-555-5555', url: 'http://UnattachedExpert.com' }
	@published_profile_data ||= { first_name: 'Sandy', middle_name: 'A', last_name: 'Known_58792040839757',
		company_name: 'Co_58792040839757', primary_phone: '888-555-7777', url: 'http://KnownExpert.com',
		is_published: true }
	@published_profile_data_2 ||= { first_name: 'Yeti', middle_name: 'B', last_name: 'Foot_6594098385732',
		company_name: 'Co_6594098385732', primary_phone: '888-555-6666', url: 'http://yetibfoot.com',
		is_published: true }
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

def create_profile_for_payable_provider
	customer_file = FactoryGirl.create :customer_file
	@profile_for_payable_provider = customer_file.provider.profile
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
		'url'
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

def location_address_selector(which)
	selector = '.map div:first-of-type + .location_block'
	selector += ' + .location_block' if which.strip == 'second'
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

Given /^a published profile exists with company name "(.*?)"$/ do |company_name|
	create_published_profile company_name: company_name
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

Given /^the predefined category of "(.*?)" is associated with the "(.*?)" and "(.*?)" subcategories$/ do |cat, subcat1, subcat2|
	category = cat.to_category
	category.is_predefined = true
	category.subcategories = [subcat1.to_subcategory, subcat2.to_subcategory]
	category.save
end

Given /^the predefined subcategory of "(.*?)" is associated with the "(.*?)" and "(.*?)" services$/ do |subcat, svc1, svc2|
	subcat.to_subcategory.services = [svc1.to_service, svc2.to_service]
end

Given /^the "(.*?)" and "(.*?)" services are predefined$/ do |svc1, svc2|
	[svc1, svc2].each do |svc|
		service = svc.to_service
		service.is_predefined = true
		service.save
	end
end

Given /^there is an unclaimed profile$/ do
	create_unattached_profile
end

Given /^there is an unclaimed profile with the "(.*?)" and "(.*?)" specialties$/ do |spec1, spec2|
	create_unattached_profile specialties: [spec1.to_specialty, spec2.to_specialty]
end

Given /^I visit the (view|edit|admin view|admin edit) page for (?:a|an|the)( existing)? (claimed|published|unclaimed|unpublished|current) profile( with no locations| with one location| with no reviews| with one review| with remote consultations)?$/ do |page, existing, type, items|
	case type
	when /unclaimed|unpublished/
		create_unattached_profile unless existing
		find_unattached_profile
	when /claimed|published/
		create_published_profile unless existing
		find_published_profile
	end
	
	case items.try(:sub, /\A\s*with\s*/, '')
	when 'no locations'
		@profile.locations.map &:destroy
	when 'one location'
		# Associate it with the profile created here.
		FactoryGirl.create(:location, profile: @profile)
	when 'no reviews'
		@profile.reviews.map &:destroy
	when 'one review'
		# The review needs a reviewer associated for display purposes.
		# Associate it with the profile created here.
		FactoryGirl.create(:review, reviewer: FactoryGirl.create(:parent), profile: @profile)
	when 'remote consultations'
		@profile.locations.map &:destroy
		@profile.consult_remotely = true
		@profile.save
	end
	
	sleep 4 if items.present? # Wait for the cached count updates to complete.
	
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

Given /^a published profile with last name "(.*?)", specialty "(.*?)", and postal code "(.*?)"$/ do |name, spec, postal_code|
	create_published_profile
	@published_profile.last_name = name
	@published_profile.specialties = [spec.to_specialty]
	@published_profile.locations = [FactoryGirl.create(:location, postal_code: postal_code)]
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
	@published_profile.locations = [FactoryGirl.create(:location, city: city, region: state, country: 'US')]
	@published_profile.save
end

Given /^another published profile with city "(.*?)" and state "(.*?)"$/ do |city, state|
	create_published_profile_2
	@published_profile_2.locations = [FactoryGirl.create(:location, city: city, region: state, country: 'US')]
	@published_profile_2.save
end

Given /^(my|a published) profile with cities "(.*?)" and "(.*?)" and states "(.*?)" and "(.*?)"$/ do |which_profile, city1, city2, state1, state2|
	profile = case which_profile
	when 'a published'
		create_published_profile
	else
		create_profile
	end
	profile.locations = [FactoryGirl.create(:location, city: city1, region: state1, country: 'US'),
		FactoryGirl.create(:location, city: city2, region: state2, country: 'US')]
	profile.save
end

Given /^a published profile with city "(.*?)", region "(.*?)"(?:,) and country "(.*?)"$/ do |city, region, country|
	create_published_profile
	@published_profile.locations = [FactoryGirl.create(:location, city: city, region: region, country: country)]
	@published_profile.save
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

Given /^a profile for a payable provider$/ do
	create_profile_for_payable_provider
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

Given /^I visit a published unclaimed profile?$/ do
	create_unattached_profile({is_published: true})
	visit profile_path(@unattached_profile)
end

Given /^my profile is published$/ do
	find_user_profile
	@profile.is_published = true
	@profile.save
end

Given /^I have an announcement with "(.*?)" headline in my profile$/ do |headline_text|
	announcement_data = {profile: @user.profile, headline: headline_text}
	@user.profile.profile_announcements = [FactoryGirl.create(:profile_announcement, announcement_data)]
	@user.profile.save
end

Given /^the "(.*?)" specialties exist$/ do |specialties|
	specialties.strip.split(/,\s+(?:and\s+)?/).each do |name|
		FactoryGirl.create :specialty, name: name
	end
end

### WHEN ###

When /^I view my profile$/ do
  visit my_profile_path
end

# Requires javascript.
When /^I enter( | new | my )profile information$/ do |which|
	profile_data = (which.strip == 'my' ? @profile_data : @unattached_profile_data)
	find('#display_name *', match: :first).click
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

When /^I select the "(.*?)" category$/ do |cat|
	within('.expertise_selection') do
		check MyHelpers.profile_categories_id(cat.to_category.id)
	end
end

When /^I select the "(.*?)" and "(.*?)" categories$/ do |cat1, cat2|
	within('.expertise_selection') do
		check MyHelpers.profile_categories_id(cat1.to_category.id)
		check MyHelpers.profile_categories_id(cat2.to_category.id)
	end
end

When /^I select the "(.*?)" subcategory$/ do |subcat|
	subcategory = subcat.to_subcategory
	within('.expertise_selection') do
		check MyHelpers.profile_subcategories_id(subcategory.categories.first.id, subcategory.id)
	end
end

When /^I select the "(.*?)" and "(.*?)" subcategories$/ do |subcat1, subcat2|
	subcategory1 = subcat1.to_subcategory
	subcategory2 = subcat2.to_subcategory
	within('.expertise_selection') do
		check MyHelpers.profile_subcategories_id(subcategory1.categories.first.id, subcategory1.id)
		check MyHelpers.profile_subcategories_id(subcategory2.categories.first.id, subcategory2.id)
	end
end

When /^I select the "(.*?)" service$/ do |svc|
	service = svc.to_service
	within('.expertise_selection') do
		check MyHelpers.profile_services_id(service.subcategories.first.id, service.id)
	end
end

When /^I select the "(.*?)" and "(.*?)" services$/ do |svc1, svc2|
	service1 = svc1.to_service
	service2 = svc2.to_service
	within('.expertise_selection') do
		check MyHelpers.profile_services_id(service1.subcategories.first.id, service1.id)
		check MyHelpers.profile_services_id(service2.subcategories.first.id, service2.id)
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
		fill_in MyHelpers.profile_custom_services_id('1'), with: "#{svc1}\r\n"
		fill_in MyHelpers.profile_custom_services_id('2'), with: svc2
	end
end

When /^I uncheck the "(.*?)" specialty$/ do |spec|
	within('.predefined_specialties') do
		uncheck MyHelpers.profile_specialties_id(spec.to_specialty.id)
	end
end

# This step requires javascript.
When /^I add the "(.*?)" and "(.*?)" custom specialties$/ do |spec1, spec2|
	within('.expertise_profile .custom_specialties') do
		click_button 'add_custom_specialties_text_field'
		fill_in MyHelpers.profile_custom_specialties_id('1'), with: spec1
		click_button 'add_custom_specialties_text_field'
		fill_in MyHelpers.profile_custom_specialties_id('2'), with: spec2
	end
end

# This step requires javascript.
When /^I add the "(.*?)" and "(.*?)" custom specialties using enter$/ do |spec1, spec2|
	within('.expertise_profile .custom_specialties') do
		click_button 'add_custom_specialties_text_field'
		fill_in MyHelpers.profile_custom_specialties_id('1'), with: "#{spec1}\r\n"
		fill_in MyHelpers.profile_custom_specialties_id('2'), with: spec2
	end
end

# This step requires javascript.
When /^I fill in the "(.*?)" specialty$/ do |spec|
	within('#specialties .specialty_names') do
		fill_in MyHelpers.profile_specialty_names_id('1'), with: spec
	end
end

# This step requires javascript.
When /^I fill in the "(.*?)" and "(.*?)" specialties$/ do |spec1, spec2|
	within('#specialties .specialty_names') do
		fill_in MyHelpers.profile_specialty_names_id('1'), with: spec1
		fill_in MyHelpers.profile_specialty_names_id('2'), with: spec2
	end
end

# This step requires javascript.
When /^I fill in the "(.*?)" and "(.*?)" specialties using enter$/ do |spec1, spec2|
	within('#specialties .specialty_names .text_field:last-of-type') do
		find('input').set "#{spec1}\r\n"
	end
	within('#specialties .specialty_names .text_field:last-of-type') do
		find('input').set spec2
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

When /^I visit the payable provider's profile page$/ do
	visit profile_path(@profile_for_payable_provider)
end

When /^I visit the payable provider's authorization page$/ do
	visit authorize_payment_path(@profile_for_payable_provider)
end

When /^I visit the payable provider's payment information page$/ do
	visit about_payments_profile_path(@profile_for_payable_provider)
end

When /^I click on the link for an unclaimed profile$/ do
	click_link "#{@unattached_profile_data[:first_name]} #{@unattached_profile_data[:middle_name]} #{@unattached_profile_data[:last_name]}"
end

When /^I open the "(.*?)" formlet$/ do |formlet|
	find("##{formlet_id formlet} .editable", match: :first).click
end

When /^I enter "(.*?)" in the "(.*?)" field of the "(.*?)" formlet$/ do |text, field, formlet|
	pending 'editor and admin functions in new design' if ['Admin notes', 'Lead generator'].include? field
	within("##{formlet_id formlet}") do
		fill_in field, with: text
	end
end

When /^I select "(.*?)" as the "(.*?)" in the "(.*?)" formlet$/ do |option, select_box, formlet|
	within("##{formlet_id formlet}") do
		select option, from: select_box, match: :first
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
	sleep 5 # In case this click caused an AJAX call, give it some time to finish to avoid database deadlock with later cleanup phase.
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
	click_link I18n.t('views.profile.view.invitation_to_claim_link'), match: :first
	fill_in 'Email', with: email
	click_button 'send_invitation_profile'
end

When /^I preview the invitation to "(.*?)" to claim the profile$/ do |email|
	click_link I18n.t('views.profile.view.invitation_to_claim_link'), match: :first
	fill_in 'Email', with: email
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

When /^I (?:should )?see step "(one|two|three)" of "(.*?)" formlet$/ do |visible_step, formlet|
	within("##{formlet_id formlet}") do
		# Capybara (or something) seems to be out of sync with actual visibility, so match any visibility state and use the "aria-hidden" class to infer visibility.
		%w(one two three).each do |step|
			if step == visible_step
				expect(page).to have_css("li.step_#{step}:not(.aria-hidden)", visible: :all)
			else
				expect(page).to have_css("li.step_#{step}.aria-hidden", visible: :all)
			end
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

When /^I enter a (valid|past) start date and (?:a)? (past|future|no) end date in the Date range section of the "(.*?)" formlet$/ do |start_date_when, end_date_when, formlet|
	if start_date_when == 'valid'
		start_date = Time.zone.now
	else
		start_date = Time.zone.now - 2.weeks
	end
	end_date = Time.zone.now + 1.weeks if end_date_when == 'future'
	end_date = Time.zone.now - 1.weeks if end_date_when == 'past'
	within("##{formlet_id formlet}") do
		fill_in "From", with: start_date.strftime(Announcement::DATEFORMAT)
		fill_in "to", with: end_date.strftime(Announcement::DATEFORMAT) if end_date.present?
	end
end

When /^I search for my profile$/ do
	find_user_profile
	query = @profile.display_name_or_company
	visit search_providers_path query: query
end

### THEN ###

Then /^I should see my profile information$/ do
	within('.profile h1') do
		expect(page).to have_content @profile.first_name
		expect(page).to have_content @profile.last_name
	end
end

Then /^meta\-data should contain "(.*?)"$/ do |text|
	expect(page).to have_selector("meta[content~=\"#{text.downcase}\"]", visible: false)
end

Then /^I should see one of my specialties$/ do
	expect(page).to have_content @profile.specialties.first.name
end

Then /^I should land on the profile view page$/ do
	expect(current_path).to eq my_profile_path
end

Then /^I should (?:land|remain) on the profile edit page$/ do
	expect(current_path).to eq edit_my_profile_path
end

Then /^my email address should be saved to my user record$/ do
	expect(@user.email).to eq @visitor[:email]
end

Then /^my country code should be set to "(.*?)"$/ do |country|
	find_user_profile
	@profile.locations.each { |location| expect(location.country).to eq country}
end

Then /^(?:my|the) profile should show "([^\"]+)"$/ do |value|
	expect(page).to have_content value
end

Then /^(?:my|the) profile should not show "([^\"]+)"$/ do |value|
	expect(page).to_not have_content value
end

Then /^(?:my|the) profile should show "([^\"]+)" within "([^\"]+)"$/ do |value, css_class_name|
	within(".#{css_class_name}") do
		expect(page).to have_content value
	end
end

Then /^(?:my|the) profile should show "([^\"]+)" within the (first|second) location address$/ do |value, which|
	within(location_address_selector which) do
		expect(page).to have_content value
	end
end

Then /^(?:my|the) profile should not display the (first|second) location$/ do |which|
	expect(page).to_not have_css(location_address_selector which)
end

Then /^my profile should have no locations$/ do
	find_user_profile
	expect(@profile.locations.size).to eq 0
end

Then /^the unclaimed profile should have no locations$/ do
	find_unattached_profile
	expect(@profile.locations.size).to eq 0
end

Then /^the "(.*?)" and "(.*?)" specialties should appear in the profile edit input list$/ do |name1, name2|
	within("#specialties .specialty_names") do
		expect(find("##{MyHelpers.profile_specialty_names_id('1')}").value).to have_content name1
		expect(find("##{MyHelpers.profile_specialty_names_id('2')}").value).to have_content name2
	end
end

Then /^then I should be offered the "(.*?)" and "(.*?)" (.*?)$/ do |name1, name2, things|
	within("#services .#{things}") do
		expect(page).to have_content name1
		expect(page).to have_content name2
	end
end

Then /^I should be offered no (.*?)$/ do |things|
	within("#services .#{things}") do
		expect(page).to_not have_content FactoryGirl.attributes_for(things.singularize.to_sym)[:name]
	end
end

Then /^my profile edit page should show "([^\"]+)" displayed (as a link )?in the "([^\"]+)" area$/ do |value, link, formlet|
	selector = "##{formlet_id formlet}"
	selector += ' a' if link.present?
	within(selector, match: :first) do
		expect(page).to have_content value
	end
end

Then /^my profile edit page should show "([^\"]+)" and "([^\"]+)" displayed in the "([^\"]+)" area$/ do |value1, value2, formlet|
	within("##{formlet_id formlet}") do
		expect(page).to have_content value1
		expect(page).to have_content value2
	end
end

Then /^I should see more than one profile$/ do
	expect(page).to have_content @profile_data[:company_name]
	expect(page).to have_content @profile_data_2[:company_name]
end

Then /^I should not see profile data$/ do
	expect(page).to_not have_content @profile_data[:company_name]
end

Then /^I should not see profile data that is not my own$/ do
	expect(page).to_not have_content @profile_data_2[:company_name]
end

Then /^I should see published profile data$/ do
	expect(page).to have_content @published_profile_data[:company_name]
end

Then /^I should see a profile edit form$/ do
	expect(page).to have_content I18n.t 'views.profile.edit.editing_tip'
end

Then /^I should see the new profile data$/ do
	expect(page).to have_content @unattached_profile_data[:first_name]
	expect(page).to have_content @unattached_profile_data[:middle_name]
	expect(page).to have_content @unattached_profile_data[:last_name]
	# expect(page).to have_content MyHelpers.strip_url(@unattached_profile_data[:url])
end

Then /^I should land on the view page for the unclaimed profile$/ do
	find_unattached_profile
	expect(current_path).to eq profile_path(@profile)
end

Then /^I should land on the edit page for the unclaimed profile$/ do
	find_unattached_profile
	expect(current_path).to eq edit_profile_path(@profile)
end

Then /^the last name in the unclaimed profile should be "(.*?)"$/ do |last_name|
	find_unattached_profile
	expect(@profile.last_name).to eq last_name
end

Then /^the (?:new|previously unpublished) profile should be published$/ do
	find_unattached_profile
	expect(@profile.is_published).to be_truthy
end

Then /^the search area tag in the unclaimed profile should be "(.*?)"$/ do |tag|
	find_unattached_profile
	expect(@profile.locations.first.search_area_tag.name).to eq tag
end

# Dynamic display showing what the display name will be after saving.
Then /^the display name should be dynamically shown as "(.*?)"$/ do |display_name|
	within('.display_name_area') do
		expect(page).to have_content display_name
	end 
end

Then /^I should see profile data for that user$/ do
	within('.links .url') do
		expect(page).to have_content MyHelpers.strip_url(@profile_data[:url])
	end
end

Then /^I should see "(.*?)" in the page title$/ do |words|
	expect(title).to have_content words
end

Then /^the profile should be attached to my account$/ do
	find_user_profile
	expect(@profile).to eq @unattached_profile
end

Then /^I should see form fields for an extra location on my profile edit page$/ do
	expect(page).to have_css '#locations form .fields + .fields'
end

Then /^I should see form fields for an extra location on the admin profile edit page$/ do
	expect(page).to have_css '.location_contact_profile .fields + .fields'
end

Then /^I should see form fields for a (second )?review on the admin profile edit page$/ do |which|
	expect(page).to have_css ".reviews .fields#{' + .fields' if which.try(:strip) == 'second'}"
end

Then /^I should be asked to replace my existing profile$/ do
	within('a[id="claim_profile_confirm_link"]') do
		expect(page).to have_content 'Click here'
	end
end

Then /^edit my profile page should show "(.*?)" image as my profile photo$/ do |file_name|
	using_wait_time 3 do
		expect(page.has_css?("img[src*='#{file_name}']", :count => 2)).to be true
		file_path = Rails.root.join("public/profile_photos/#{@profile.id}", file_name)
		expect(File.exist?(file_path)).to be true
		File.delete(file_path)
	end
end

Then /^I should see a Google Map$/ do
	within 'body' do
		expect(page).to have_xpath("//script[starts-with(@src, 'https://maps.googleapis.com/maps/api')]", visible: false)
	end
	within('#map_canvas') do
		expect(page).to_not be_blank
	end
end

# Need the following two step definitions because for some strange reason Sunspot will not commit updates to Solr when we are testing with javascript and therefore we can't use javascript when testing search.
Then /^I should see a Google Map container$/ do
	expect(page).to have_css('#map_canvas')
end
Then /^I should not see a Google Map container$/ do
	expect(page).to_not have_css('#map_canvas')
end

Then /^I should see (?:the )"(.*?)" message$/ do |locale_path|
 	expect(page).to have_content I18n.t locale_path
end

Then /^I should see the "(.*?)" formlet$/ do |formlet|
	expect(page).to have_css("##{formlet_id formlet}.formlet", visible: true)
end

Then /^I should see "(.*?)" in the "(.*?)" formlet$/ do |text, formlet|
	within("##{formlet_id formlet}") do
		expect(page).to have_content text
	end
end

Then /^I should see an edit tab$/ do
	expect(page).to have_content I18n.t('views.profile.edit.edit_tab')
end

Then /^the administrator should receive (an|no|\d+) emails?$/ do |amount|
  expect(unread_emails_for(@user.email).size).to eq parse_email_count(amount)
end

Then /^I should see an invitation to "(.*?)" to claim their profile$/ do |email|
	within '.invitation_state' do
		expect(page).to have_content email
	end
end

Then /^I should see the photo editor$/ do
	pending 'figure out why Capybara does not recognize the visible state of the Aviary photo editor'
	using_wait_time 3 do
		expect(page).to have_css('#avpw_controls')
	end
end
