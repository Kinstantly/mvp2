class ContactBlocker < ActiveRecord::Base
	has_paper_trail # Track changes to each contact blocker.
	
	attr_accessible :email
	
	# If you want to make other attributes accessible to admin, use a role, e.g.,
	# attr_accessible :email, :email_delivery_id, as: :admin
	
	belongs_to :email_delivery
	
	validates :email, email: true
	
	# Update attributes with given values as usual.
	# Additionally, if this contact_blocker is associated with an email_delivery and the given email is different from the email_delivery recipient, also block that recipient.
	# Prevent duplicates.
	def update_attributes_from_email_delivery(values)
		if self.class.find_by_email values[:email]
			if email_delivery
				email_delivery.contact_blockers.where(email: email_delivery.recipient).first_or_create
			else
				true
			end
		elsif update_attributes values
			if email_delivery && values[:email] != email_delivery.recipient
				email_delivery.contact_blockers.where(email: email_delivery.recipient).first_or_create
			else
				true
			end
		else
			false
		end
	end
end
