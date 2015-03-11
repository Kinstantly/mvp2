class StripeInfo < ActiveRecord::Base
	has_paper_trail # Track changes to each Stripe info record.
	
	belongs_to :user
	has_many :stripe_customers
	
	after_save :touch_profile
	after_destroy :touch_profile
	
	validates_presence_of :stripe_user_id, :access_token, :publishable_key
	
	# Accepts authorization values obtained via the "omniauth.auth" request header.
	def configure_authorization(auth_values)
		self.stripe_user_id = auth_values.try(:[], :uid)
		self.access_token = auth_values.try(:[], :credentials).try(:[], :token)
		self.publishable_key = auth_values.try(:[], :extra).try(:[], :raw_info).try(:[], :stripe_publishable_key)
		@stripe_account = nil
		if save
			create_announcement
			welcome_provider
			true
		else
			false
		end
	end
	
	# Returns true if the associated Stripe account is fully enabled.
	# The account should only be fully enabled if no further verification is required.
	def fully_enabled?
		if stripe_account
			@stripe_account[:details_submitted] && @stripe_account[:transfer_enabled] && @stripe_account[:charge_enabled]
		else
			false
		end
	end
	
	# Returns the associated Stripe::Account object.
	def stripe_account
		@stripe_account ||= Stripe::Account.retrieve access_token
	end
	
	private
	
	# Touch profile to invalidate fragment cache(s) in case we need to update payment info on the profile page.
	def touch_profile
		user.try(:profile).try(:touch)
	end
	
	# Create a payment announcement if not already done.
	def create_announcement
		if (profile = user.profile) and profile.payment_profile_announcements.blank?
			profile.payment_profile_announcements.create(PaymentProfileAnnouncement::INITIAL_ATTRIBUTE_VALUES.merge({
				button_url: Rails.application.routes.url_helpers.about_payments_profile_url(profile, host: default_host),
				start_at: Time.zone.now
			}))
		end
	end
	
	# Welcome the newly connected provider.
	def welcome_provider
		StripeConnectMailer.welcome_provider(user).deliver
	end
end
