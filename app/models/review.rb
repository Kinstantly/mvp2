class Review < ActiveRecord::Base
	has_paper_trail # Track changes to each review.
	
	attr_accessible :body, :reviewer_email, :reviewer_username, :rating_attributes
	
	belongs_to :profile
	has_one :rating, dependent: :destroy
	accepts_nested_attributes_for :rating, allow_destroy: true
	belongs_to :reviewer, class_name: 'User'
	
	attr_writer :reviewer_username
	
	# Define minimum and/or maximum length of string and text attributes in a publicly accessible way.
	# This allows them to be used at the view layer for character counts in input and textarea tags.
	MIN_LENGTHS = {
		body: 20
	}
	MAX_LENGTHS = {
		body: 1000,
		reviewer_email: User::MAX_LENGTHS[:email],
		reviewer_username: User::MAX_LENGTHS[:username]
	}
	
	# reviewer_email and reviewer_username are validated indirectly by the user model.
	before_validation :require_reviewer
	validate :validate_rating
	validates :body, length: {minimum: MIN_LENGTHS[:body], maximum: MAX_LENGTHS[:body]}
	
	# If we are doing a nested update and the editor is attempting to change the reviewer,
	#   force a save even if no other attribute is being modified.
	def reviewer_email=(new_value)
		@reviewer_email = new_value
		self.updated_at = Time.zone.now if persisted? && (reviewer.nil? || reviewer.email.try(:casecmp, new_value) != 0)
	end
	
	def reviewer_email
		@reviewer_email || reviewer.try(:email)
	end
	
	def reviewer_username
		@reviewer_username || reviewer.try(:username)
	end
	
	def rating
		super || build_rating
	end
	
	private
	
	# Make sure we have a valid reviewer assigned.
	def require_reviewer
		if reviewer_email.blank?
			# Don't try to find or build a user using a blank email address.
			errors.add :reviewer_email, I18n.t('activerecord.errors.messages.blank')
			return true
		end
		
		user = User.where(email: reviewer_email).first_or_initialize do |u|
			# Code in this block is run ONLY if this is a new record.
			u.username = reviewer_username
			u.add_role :client
			u.password = User.generate_password
			# Don't notify user that they have an account.
			# We will notify them once we have implemented a mechanism to force them to set their password after confirming.
			u.skip_confirmation_notification!
		end
		
		user.save if user.new_record?
		if (user_errors = user.errors).present?
			errors.add :reviewer_email, user_errors.delete(:email) if user_errors[:email]
			errors.add :reviewer_username, user_errors.delete(:username) if user_errors[:username]
			errors.add :reviewer, user_errors.full_messages.join('; ') if user_errors.present?
		else
			self.reviewer = user
		end
		true
	end
	
	def validate_rating
		unless rating.valid?
			if rating.errors.present?
				errors.add :rating, rating.errors.full_messages.join('; ')
			else
				errors.add :rating, I18n.t('activerecord.errors.review.attributes.rating.invalid')
			end
		end
		true
	end
end
