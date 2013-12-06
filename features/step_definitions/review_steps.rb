# Tip: to view the page, use: save_and_open_page

### Utility methods ###

def review_selector(which)
	case which
	when 'new'
		'.new_review_div'
	when 'first'
		'.edit_review_div'
	when 'second'
		'.edit_review_div + .edit_review_div'
	end
end

### GIVEN ###

### WHEN ###

When /^I enter "(.*?)"(?: as the )?(reviewer email|reviewer username|title|good-to-know)? (?:of|in) the (new|first|second) review on the (?:admin profile edit|review) page$/ do |text, field, which|
	attribute = case field
	when 'reviewer email'
		:reviewer_email
	when 'reviewer username'
		:reviewer_username
	when 'title'
		:title
	when 'good-to-know'
		:good_to_know
	else
		:body
	end
	label = Review.human_attribute_name attribute
	within(review_selector which) do
		fill_in label, with: text
	end
end

When /^I give a rating of "(.*?)" (?:in|on) the (new|first|second) review on the admin profile edit page$/ do |score, which|
	within(review_selector which) do
		choose "rating_score_#{score}"
	end
end

When /^I click "(.*?)" (?:in|on) the (new|first|second) review on the (?:admin profile edit|review) page$/ do |clicked, which|
	within(review_selector which) do
		click_link_or_button clicked
	end
end

When /^I visit the review page for the current profile$/ do
	visit new_review_for_profile(@profile)
end

When /^I click on the review link$/ do
	click_link @published_profile.display_name_or_company
end

### THEN ###

Then /^the profile should have (no|\d+) reviews?$/ do |how_many|
	@profile.should have(how_many).reviews
end

Then /^the profile should show the review$/ do
	within('#reviews') do
	  page.should have_content @profile.reviews.first.body
	end
end

Then /^I should land on the view page for the published profile$/ do
	find_unattached_profile
	current_path.should == profile_path(@published_profile)
end

Then /^I should land on the review form of the profile$/ do
	find_unattached_profile
	current_path.should == new_review_for_profile_path(@published_profile)
end