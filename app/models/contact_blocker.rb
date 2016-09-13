class ContactBlocker < ActiveRecord::Base
	has_paper_trail # Track changes to each contact blocker.
	
	DEFAULT_ACCESSIBLE_ATTRIBUTES = [ :email ]
	
	# Strip leading and trailing whitespace from input intended for these attributes.
	auto_strip_attributes :email
	
	belongs_to :email_delivery
	
	validates :email, email: true
	
	scope :order_by_descending_id, -> { order('id DESC') }
	
	after_save :remove_email_subscriptions
	
	# Update attributes with given values as usual.
	# Additionally, if this contact_blocker is associated with an email_delivery and the given email is different from the email_delivery recipient, also block that recipient.
	# Prevent duplicates.
	def update_attributes_from_email_delivery(values)
		if self.class.find_by_email_ignore_case(values[:email]) || update_attributes(values)
			if email_delivery
				email_delivery.contact_blockers.where(email: email_delivery.recipient).first_or_create
			else
				true
			end
		else
			false
		end
	end
	
	# Class method to find the first matching contact blocker by email address while ignoring case.
	def self.find_by_email_ignore_case(email)
		where('lower(email) = ?', email.strip.downcase).first
	end
	
	private
	
	def remove_email_subscriptions
		user = User.find_by_email_ignore_case email
		user.remove_email_subscriptions if user
	end
end
