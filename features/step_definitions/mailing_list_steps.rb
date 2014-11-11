# Tip: to view the page, use: save_and_open_page

### UTILITY METHODS ###

def subscribed_to_all_mailing_lists_for(user=@user)
	user.parent_marketing_emails = true
	user.parent_newsletters = true
	user.provider_marketing_emails = true
	user.provider_newsletters = true
	user.save
end

### GIVEN ###

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


### THEN ###

Then /^I should not be subscribed to any mailing lists$/ do
	@user.reload
	@user.parent_marketing_emails.should be_false
	@user.parent_newsletters.should be_false
	@user.provider_marketing_emails.should be_false
	@user.provider_newsletters.should be_false
	@user.parent_marketing_emails_leid.should be_nil
	@user.parent_newsletters_leid.should be_nil
	@user.provider_marketing_emails_leid.should be_nil
	@user.provider_newsletters_leid.should be_nil
end

Then /^I should be subscribed only to the provider mailing lists but not yet synced to the list server$/ do
	@user.reload
	@user.parent_marketing_emails.should be_false
	@user.parent_newsletters.should be_false
	@user.provider_marketing_emails.should be_true
	@user.provider_newsletters.should be_true
	@user.parent_marketing_emails_leid.should be_nil
	@user.parent_newsletters_leid.should be_nil
	@user.provider_marketing_emails_leid.should be_nil
	@user.provider_newsletters_leid.should be_nil
end

Then /^I should be subscribed only to the provider mailing lists and synced to the list server$/ do
	@user.reload
	@user.parent_marketing_emails.should be_false
	@user.parent_newsletters.should be_false
	@user.provider_marketing_emails.should be_true
	@user.provider_newsletters.should be_true
	@user.parent_marketing_emails_leid.should be_nil
	@user.parent_newsletters_leid.should be_nil
	@user.provider_marketing_emails_leid.should_not be_nil
	@user.provider_newsletters_leid.should_not be_nil
end

Then /^I should be subscribed to only the parent mailing lists but not yet synced to the list server$/ do
	@user.reload
	@user.parent_marketing_emails.should be_true
	@user.parent_newsletters.should be_true
	@user.provider_marketing_emails.should be_false
	@user.provider_newsletters.should be_false
	@user.parent_marketing_emails_leid.should be_nil
	@user.parent_newsletters_leid.should be_nil
	@user.provider_marketing_emails_leid.should be_nil
	@user.provider_newsletters_leid.should be_nil
end

Then /^I should be subscribed to only the parent mailing lists and synced to the list server$/ do
	@user.reload
	@user.parent_marketing_emails.should be_true
	@user.parent_newsletters.should be_true
	@user.provider_marketing_emails.should be_false
	@user.provider_newsletters.should be_false
	@user.parent_marketing_emails_leid.should_not be_nil
	@user.parent_newsletters_leid.should_not be_nil
	@user.provider_marketing_emails_leid.should be_nil
	@user.provider_newsletters_leid.should be_nil
end

Then /^I should be subscribed to the provider mailing lists$/ do
	@user.reload
	@user.provider_marketing_emails.should be_true
	@user.provider_newsletters.should be_true
end

Then /^I should not be subscribed to the provider mailing lists$/ do
	@user.reload
	@user.provider_marketing_emails.should be_false
	@user.provider_newsletters.should be_false
end
