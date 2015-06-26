# Tip: to view the page, use: save_and_open_page

### UTILITY METHODS ###

def subscribed_to_all_mailing_lists_for(user=@user)
	mailing_lists.each do |list|
		user[list] = true
	end
	user.save
end

### GIVEN ###

Given /^there are no existing mailing list subscriptions$/ do
	empty_mailing_lists
end

Given /^I am subscribed to all mailing lists$/ do
	subscribed_to_all_mailing_lists_for @user
end

### WHEN ###

When /^an administrator unsubscribes me from all mailing lists$/ do
	me = @user
	create_admin_user
	sign_in_admin
	visit new_contact_blocker_path
	fill_in 'Email address', with: me.email
	click_button 'Create Contact blocker'
	@user = me
end

When /^I visit the newsletter-only sign-up page and subscribe to the "(.*?)" mailing lists?(?: with email "(.*?)")?$/ do |lists, email|
	email ||= (create_visitor && @visitor[:email])
	list_names = lists.split(/,?\s+(?:and\s+)?/)
	visit '/newsletter'
	within('#sign_up') do
		list_names.each do |list_name|
			check list_name
		end
		fill_in 'Email', with: email
	end
	click_button 'sign_up_button'
end

### THEN ###

Then /^I should only be subscribed to the "(.*?)" mailing lists?(?: and| but)( not)? synced to the list server$/ do |lists, not_synced|
	@user.reload
	subscribed_mailing_lists = lists.split(/,?\s+(?:and\s+)?/)
	mailing_lists.each do |list|
		if subscribed_mailing_lists.include?(list) 
			@user[list].should be_true
			if not_synced.present?
				@user["#{list}_leid"].should be_nil
			else
				@user["#{list}_leid"].should be_present
			end
		else
			@user[list].should be_false
			@user["#{list}_leid"].should be_nil
		end
	end
end

Then /^I should be subscribed to all mailing lists$/ do
	@user.reload
	mailing_lists.each do |list|
		@user[list].should be_true
		@user["#{list}_leid"].should be_present
	end
end

Then /^I should not be subscribed to any mailing lists$/ do
	@user.reload
	mailing_lists.each do |list|
		@user[list].should be_false
		@user["#{list}_leid"].should be_nil
	end
end
