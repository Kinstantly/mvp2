# Tip: to view the page, use: save_and_open_page

### UTILITY METHODS ###

def create_visitor
  @visitor ||= { :email => "example@kinstantly.com",
    :password => "P1eas@nt", :password_confirmation => "P1eas@nt" }
  @visitor_2 ||= { :email => "second_example@kinstantly.com",
    :password => "P1eas@ntly", :password_confirmation => "P1eas@ntly" }
  @admin_user ||= { :email => "admin_example@kinstantly.com",
    :password => "P1eas@nt", :password_confirmation => "P1eas@nt" }
  @payable_provider ||= { :email => "payable_provider@kinstantly.com",
    :password => "P1eas@nton", :password_confirmation => "P1eas@nton" }
end

def find_user
  @user ||= User.where(:email => @visitor[:email]).first
end

def refresh_user
  @user = User.where(:email => @visitor[:email]).first
end

def create_unconfirmed_user
  create_visitor
  delete_user
  sign_up
  visit '/users/sign_out'
end

def create_user(options={})
  create_visitor
  delete_user
  @user = FactoryGirl.create(:expert_user, @visitor.merge(options))
end

def create_client_user(options={})
  create_visitor
  delete_user
  @visitor[:username] = 'UsernameOfClient'
  @user = FactoryGirl.create(:client_user, @visitor.merge(options))
end

def create_admin_user(options={})
  create_visitor
  @user = User.find_by_email(@admin_user[:email]) || FactoryGirl.create(:admin_user, @admin_user.merge(options))
end

def create_profile_editor(options={})
  create_user options
  @user.add_role :profile_editor
  @user.save
end

def create_user_2
	create_visitor
	@user_2 ||= User.where(:email => @visitor_2[:email]).first
	@user_2.destroy unless @user_2.nil?
	@user_2 = FactoryGirl.create(:expert_user, @visitor_2)
end

def create_payable_provider
	create_visitor
	@user = FactoryGirl.create :payable_provider, @payable_provider
end

def create_client_of_payable_provider
	user = create_client_user
	customer = FactoryGirl.create :customer_with_card, user: user
	FactoryGirl.create :customer_file, customer: customer
	user
end

def delete_user
  @user ||= User.where(:email => @visitor[:email]).first
  @user.destroy unless @user.nil?
end

def sign_up(sign_up_path='/provider/sign_up')
  delete_user
  visit sign_up_path
  within('#sign_up') do
    fill_in "user_email", :with => @visitor[:email]
    fill_in "user_password", :with => @visitor[:password]
    # fill_in "user_password_confirmation", :with => @visitor[:password_confirmation]
    # fill_in "user_username", :with => @visitor[:username] if @visitor[:username]
    # fill_in "user_password_registration_special_code", :with => @visitor[:registration_special_code] if @visitor[:registration_special_code]
    click_button 'sign_up_button'
  end
  find_user
end

def sign_up_and_subscribe(sign_up_path='/provider/sign_up', mailing_lists=[])
  delete_user
  visit sign_up_path
  within('#sign_up') do
    fill_in "user_email", :with => @visitor[:email]
    fill_in "user_password", :with => @visitor[:password]
    # fill_in "user_password_confirmation", :with => @visitor[:password_confirmation]
    # fill_in "user_username", :with => @visitor[:username] if @visitor[:username]
    # fill_in "user_password_registration_special_code", :with => @visitor[:registration_special_code] if @visitor[:registration_special_code]
    mailing_lists.each do |list|
      check "user_#{list}"
    end
    click_button 'sign_up_button'
  end
  find_user
end

def sign_up_member
  sign_up '/member/sign_up'
end

def sign_in(credentials=@visitor)
  visit '/users/sign_in'
  within('#sign_in_form') do
    fill_in User.human_attribute_name(:email), :with => credentials[:email]
    fill_in User.human_attribute_name(:password), :with => credentials[:password]
    click_button 'sign_in_button'
  end
end

def sign_in_admin
  sign_in @admin_user
end

def sign_in_payable_provider
	sign_in @payable_provider
end

def load_user(who)
	case who
	when 'I'
		expect(@user).to be_present
		@user.reload
	else
		@user = User.find_by_email who
		expect(@user).to be_present
	end
end

def otp_code_for(user)
	if otp_secret_key = user.otp_secret_key
		ROTP::TOTP.new(otp_secret_key, digits: user.class.otp_length).now
	end
end

### GIVEN ###
Given /^I am not logged in$/ do
  visit '/users/sign_out'
end

Given /^I am logged in$/ do
  # create_user
  sign_in
end

Given /^I exist as a (?:user|provider)$/ do
  create_user
end

Given /^I am logged in as a provider$/ do
  create_user
  sign_in
end

Given /^I am logged in as a (?:parent|client user)$/ do
  create_client_user
  sign_in
end

Given /^I do not exist as a user$/ do
  create_visitor
  delete_user
end

Given /^I exist as an unconfirmed user$/ do
  create_unconfirmed_user
end

Given /^I am logged in as (an administrator|a profile editor)( requiring two-factor authentication)?$/ do |role, tfa|
	case role
	when 'an administrator'
		create_admin_user require_two_factor_authentication: tfa.present?
		sign_in_admin
	when 'a profile editor'
		create_profile_editor require_two_factor_authentication: tfa.present?
		sign_in
	end
end

Given /^I am a client of a payable provider$/ do
	client = create_client_of_payable_provider
	@profile_for_payable_provider = client.as_customer.customer_files.first.provider.profile
end

Given /^I (?:visit|am on) my account edit page$/ do
	visit edit_user_registration_path
end

Given /^I (?:visit|am on) my contact preferences edit page$/ do
	visit edit_user_registration_path(contact_preferences: 't')
end

Given /^chose to hide profile help by default$/ do
  @user.profile_help = false
  @user.save
end

### WHEN ###
When /^I sign in with valid credentials$/ do
  create_visitor
  sign_in
end

When /^I sign out$/ do
  visit '/users/sign_out'
end

When /^I sign up with valid user data$/ do
  create_visitor
  sign_up
end

When /^I sign up without a username$/ do
  create_visitor
  @visitor = @visitor.merge(:username => "")
  sign_up
end

When /^I sign up as a (?:non\-expert|parent) with valid user data$/ do
  create_visitor
  @visitor = @visitor.merge(:username => "hoffman")
  sign_up_member
end

When /^I sign up as a (?:non\-expert|parent) without a username$/ do
  create_visitor
  @visitor = @visitor.merge(:username => "")
  sign_up_member
end

When /^I sign up with email "([^"]*?)"$/ do |email|
  create_visitor
  @visitor = @visitor.merge(:email => email)
  sign_up
end

When /^I sign up with an invalid email$/ do
  create_visitor
  @visitor = @visitor.merge(:email => "notanemail")
  sign_up
end

When /^I sign up without a password confirmation$/ do
  create_visitor
  @visitor = @visitor.merge(:password_confirmation => "")
  sign_up
end

When /^I sign up without a password$/ do
  create_visitor
  @visitor = @visitor.merge(:password => "")
  sign_up
end

When /^I sign up with a mismatched password confirmation$/ do
  create_visitor
  @visitor = @visitor.merge(:password_confirmation => "please123")
  sign_up
end

When /^I sign up with a special code of "(.*?)"$/ do |code|
	pending 'restoration of the registration_special_code input on the sign-up form'
  create_visitor
  @visitor = @visitor.merge(:registration_special_code => code)
  sign_up
end

When /^I sign up as a (?:non\-expert|parent) with a special code of "(.*?)"$/ do |code|
	pending 'restoration of the registration_special_code input on the sign-up form'
  create_visitor
  @visitor = @visitor.merge(:username => "hoffman", :registration_special_code => code)
  sign_up_member
end

When /^I sign up on the blog site with valid data$/ do
  create_visitor
	sign_up 'in_blog/sign_up'
  # sign_up_and_subscribe 'in_blog/sign_up', ['parent_newsletters']
end

When /^I sign up on the blog site with invalid data$/ do
  create_visitor
  @visitor = @visitor.merge(:password => "")
	sign_up 'in_blog/sign_up'
  # sign_up_and_subscribe 'in_blog/sign_up', ['parent_newsletters']
end

When /^I return to the site$/ do
  visit '/'
end

When /^I sign in with a wrong email$/ do
  @visitor = @visitor.merge(:email => "wrong@example.com")
  sign_in
end

When /^I sign in with a wrong password$/ do
  @visitor = @visitor.merge(:password => "wrongpass")
  sign_in
end

When /^I edit my account details$/ do
  click_link "Edit account"
  fill_in "Current password", :with => @visitor[:password]
  click_button "Update"
end

When /^I enter a new password(?: of "([^"]*?)")?$/ do |password|
	password ||= 'kjoi4lk3j8nl'
	fill_in 'user_password', with: password
	fill_in 'user_password_confirmation', with: password
	fill_in 'user_current_password', with: @visitor[:password]
end

When /^I enter my current password$/ do
  fill_in 'user_current_password', with: @visitor[:password]
end

When /^I enter a new email address(?: of "([^"]*?)")?$/ do |email|
	email ||= "new_#{@visitor[:email]}"
	fill_in 'user_current_password', with: @visitor[:password]
	fill_in 'user_email', with: email
end

When /^I enter a new username(?: of "([^"]*?)")?$/ do |username|
	username ||= "new_#{@visitor[:username]}"
	fill_in 'user_current_password', with: @visitor[:password]
	fill_in 'user_username', with: username
end

When /^I look at the list of users$/ do
  visit '/'
end

When /^I visit the user index page$/ do
	visit users_path
end

When /^I save the account settings$/ do
	click_button 'Submit'
end

When /^I visit the account page for (?:a|an) (confirmed|unconfirmed) user$/ do |user_type|
  create_user_2
  if user_type == 'unconfirmed'
    @user_2.confirmed_at = nil
    @user_2.save
  end
  visit user_path @user_2
end

When /^I visit the account page for "([^"]+)"$/ do |email|
  visit user_path User.find_by_email email
end

When /^I click on a user account link$/ do
  click_link @user_2.email
end

When /^I (?:visit|am on) the in-blog signup page$/ do
  visit in_blog_sign_up_path
end

When /^the payable provider opens the email with subject "(.*?)"$/ do |subject|
	step "\"#{@profile_for_payable_provider.user.email}\" opens the email with subject \"#{subject}\""
end

When /^I sign up as (?:a) (parent|provider) on the (blog|regular) site and subscribe to the "(.*?)" mailing lists?$/ do |user_type, page_origin, mailing_lists|
  create_visitor
  mailing_list_array = mailing_lists.split(/,?\s+(?:and\s+)?/)
  path = '/provider/sign_up'
  if user_type == 'parent'
    path = 'member/sign_up'
  end
  if page_origin == 'blog'
    path = 'in_blog/sign_up'
  end
  sign_up_and_subscribe path, mailing_list_array
end

When /^I visit the newsletter sign-up page and subscribe to the "(.*?)" mailing lists?$/ do |mailing_lists|
  create_visitor
  sign_up_and_subscribe '/newsletter', mailing_lists.split(/,?\s+(?:and\s+)?/)
end

When /^I click on the sign[- ]?up button$/ do
	click_button 'sign_up_button'
end

When /^I submit the correct one-time password$/ do
	fill_in 'otp_code', with: otp_code_for(@user)
	click_button I18n.t('views.two_factor_authentication.submit')
end

When /^I submit an incorrect one-time password$/ do
	fill_in 'otp_code', with: sprintf('%06d', (otp_code_for(@user).to_i + 1))
	click_button I18n.t('views.two_factor_authentication.submit')
end

### THEN ###
Then /^I should be signed in$/ do
  expect(page).to have_content I18n.t('views.sign_out.label').upcase
  expect(page).to_not have_content I18n.t('views.sign_in.label')
end

Then /^I should be signed out$/ do
  expect(page).to have_content I18n.t('views.sign_in.label')
  expect(page).to_not have_content I18n.t('views.sign_out.label').upcase
end

Then /^I see an unconfirmed account message$/ do
  expect(page).to have_content I18n.t('devise.registrations.signed_up_but_unconfirmed')
end

Then /^I see a confirmed account message$/ do
  expect(page).to have_content I18n.t('devise.confirmations.confirmed')
end

Then /^I see a successful sign in message$/ do
  expect(page).to have_content I18n.t('devise.sessions.signed_in')
end

Then /^I should see a successful sign up message$/ do
  expect(page).to have_content I18n.t('devise.registrations.signed_up')
end

Then /^I should see an invalid email message$/ do
  expect(page).to have_content "#{User.human_attribute_name :email} is invalid"
end

Then /^I should see a missing password message$/ do
  expect(page).to have_content "#{User.human_attribute_name :password} #{I18n.t 'activerecord.errors.messages.blank'}"
end

Then /^I should see a missing password confirmation message$/ do
  expect(page).to have_content "#{User.human_attribute_name :password} #{I18n.t 'activerecord.errors.models.user.attributes.password.confirmation'}"
end

Then /^I should see a mismatched password message$/ do
  expect(page).to have_content "#{User.human_attribute_name :password} #{I18n.t 'activerecord.errors.models.user.attributes.password.confirmation'}"
end

Then /^I should see a missing username message$/ do
  expect(page).to have_content "#{User.human_attribute_name :username} #{I18n.t 'activerecord.errors.messages.blank'}"
end

Then /^I should see a signed out message$/ do
  expect(page).to have_content I18n.t('devise.sessions.signed_out')
end

Then /^I see an invalid login message$/ do
  expect(page).to have_content I18n.t('devise.failure.invalid')
end

Then /^I should see an account edited message$/ do
  expect(page).to have_content I18n.t('devise.registrations.updated')
end

Then /^I should see a subscriptions edited message$/ do
  expect(page).to have_content I18n.t('controllers.users.subscriptions_updated')
end

Then /^I should be an expert$/ do
  expect(@user).to be_expert
end

Then /^I should be a client$/ do
  expect(@user).to be_client
end

Then /^I should see more than one user$/ do
	expect(page).to have_content @visitor[:email]
	expect(page).to have_content @visitor_2[:email]
end

Then /^I should not see user data$/ do
	expect(page).to_not have_content @visitor[:email]
end

Then /^I should not see user data that is not my own$/ do
	expect(page).to_not have_content @visitor_2[:email]
end

Then /^I should see my username$/ do
	expect(page).to have_content @user.username
end

Then /^I should (?:be|land) on the (provider|member) (?:registration|sign[- ]up) page$/ do |role|
	path = case role
	when 'provider'
		provider_sign_up_path
	else
		member_sign_up_path
	end
	expect(page.current_path).to eq path
end

Then /^I should land on the sign-in page$/ do
  expect(current_path).to eq new_user_session_path
end

Then /^I should land on the alpha sign-up page$/ do
  expect(current_path).to eq alpha_sign_up_path
end

Then /^I should (not )?see confirmation instructions form$/ do |no|
  if no.present?
    expect(page.has_button?('Send confirmation instructions')).to be false
    # expect(page.has_css?("input[value='#{@user_2[:email]}']")).to be false
  else
    expect(page.has_button?('Send confirmation instructions')).to be true
    expect(find('input#user_email', visible: false).value).to eq @user_2[:email]
  end
end

Then /^I should (not )?land on the account page$/ do |no|
  if no.present?
    expect(current_path).to_not eq user_path @user_2
  else
    expect(current_path).to eq user_path @user_2
  end
end

Then /^I should see "(.*?)" (translated )?link to contact_preferences section of my account settings page$/ do |selector, tr|
  link_selector = tr.present? ? I18n.t(selector) : selector
  path = edit_subscriptions_url
  expect(page.has_link?(link_selector, href: path)).to be true
end

Then /^I should see the two-factor authentication page$/ do
  expect(page).to have_content I18n.t('views.two_factor_authentication.prompt')
end

Then /^I should be signed in with two-factor authentication$/ do
  expect(page).to have_content I18n.t('devise.two_factor_authentication.success')
end

Then /^I should have run out of two-factor authentication attempts$/ do
  expect(page).to have_content I18n.t('devise.two_factor_authentication.max_login_attempts_reached')
end
