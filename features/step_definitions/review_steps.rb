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

When /^I enter "(.*?)"(?: as the )?(reviewer email|reviewer username|username|title|good-to-know)? (?:of|in) the (new|first|second) review on the (?:admin profile edit|review) page$/ do |text, field, which|
	attribute = case field
	when 'reviewer email'
		:reviewer_email
	when 'reviewer username'
		:reviewer_username_admin
	when 'username'
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
		find("div#rating_score_#{score} a").click
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
	click_link 'Add your review'
end

### THEN ###

Then /^the profile should have (no|\d+) reviews?$/ do |how_many|
	expect(@profile.reload.reviews.size).to eq (how_many == 'no' ? 0 : how_many.to_i)
end

Then /^the profile should show the review$/ do
	within('#reviews') do
	  expect(page).to have_content @profile.reviews.first.body
	end
end

Then /^I should land on the view page for the published profile$/ do
	find_unattached_profile
	expect(current_path).to eq profile_path(@published_profile)
end

Then /^I should land on the review form of the profile$/ do
	find_unattached_profile
	expect(current_path).to eq new_review_for_profile_path(@published_profile)
end
