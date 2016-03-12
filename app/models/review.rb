class Review < ActiveRecord::Base
	has_paper_trail # Track changes to each review.
	
	DEFAULT_ACCESSIBLE_ATTRIBUTES = [ :body, :good_to_know, :reviewer_username ]
	EDITOR_ACCESSIBLE_ATTRIBUTES = [
		*DEFAULT_ACCESSIBLE_ATTRIBUTES,
		:title, :profile_id, :reviewer_email
	]
	
	# Strip leading and trailing whitespace from input intended for these attributes.
	auto_strip_attributes :title, :body, :good_to_know
	
	# Touch the associated profile to change the cache_key for its fragment caches.
	belongs_to :profile, counter_cache: true, touch: true
	
	# Touch the associated reviewer to change the cache_key for its fragment caches.
	belongs_to :reviewer, class_name: 'User', counter_cache: 'reviews_given_count', touch: true, counter_cache_association: :reviews_given
	# has_one :rating, dependent: :destroy # when we had one rating per review.
	# accepts_nested_attributes_for :rating, allow_destroy: true
	
	# Define minimum and/or maximum length of string and text attributes in a publicly accessible way.
	# This allows them to be used at the view layer for character counts in input and textarea tags.
	MIN_LENGTHS = {
		body: 20
	}
	MAX_LENGTHS = {
		title: 150,
		body: 4000,
		good_to_know: 500,
		reviewer_email: User::MAX_LENGTHS[:email],
		reviewer_username: User::MAX_LENGTHS[:username]
	}
	
	# validate :validate_rating
	validates :body, length: {minimum: MIN_LENGTHS[:body], maximum: MAX_LENGTHS[:body]}
	[:title, :good_to_know].each do |attribute|
			validates attribute, allow_blank: true, length: {maximum: MAX_LENGTHS[attribute]}
	end
	validates :reviewer_username, username: true
	
	scope :order_by_descending_updated_at, order('updated_at DESC')
	scope :order_by_descending_created_at, order('created_at DESC')
	
	# auto_strip_attributes doesn't like pseudo-attributes, so do the stripping here.
	def reviewer_email=(new_value)
		@reviewer_email = new_value.try(:strip)
	end
	
	def reviewer_email
		@reviewer_email || reviewer.try(:email)
	end
	
	# auto_strip_attributes doesn't like pseudo-attributes, so do the stripping here.
	def reviewer_username=(new_value)
		@reviewer_username = new_value.try(:strip)
	end
	
	def reviewer_username
		@reviewer_username || reviewer.try(:username)
	end
	
	def rating
		profile.try :rating_by, reviewer
		# super || build_rating # when we had one rating per review.
	end
	
	def rate(score)
		if profile.try :rate, score, reviewer
			true
		else
			errors.add :rating, rating.try(:errors)
			false
		end
	end
	
	def save_with_reviewer
		require_reviewer && save
	end
	
	def update_attributes_with_reviewer(attributes)
		self.reviewer_email = attributes[:reviewer_email]
		self.reviewer_username = attributes[:reviewer_username]
		save_with_reviewer && update_attributes(attributes)
	end
	
	private

	# Make sure we have a valid reviewer assigned.
	# Only to be called when processing for an administrator.
	# When processing on behalf of a regular user (the reviewer), simply associate current_user with this review.
	# Don't use the reviewer_email and reviewer_username attributes when a regular user is doing a review.
	def require_reviewer
		if reviewer_email.blank?
			# Don't try to find or build a user using a blank email address.
			errors.add :reviewer_email, I18n.t('activerecord.errors.messages.blank')
			return false
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
		
		if user.new_record?
			user.save
		elsif user.username.blank? && reviewer_username.present?
			# Allow filling in a blank username.
			user.username = reviewer_username
			user.save
		end
		
		if (user_errors = user.errors).present?
			errors.add :reviewer_email, user_errors.delete(:email) if user_errors[:email]
			errors.add :reviewer_username, user_errors.delete(:username) if user_errors[:username]
			errors.add :reviewer, user_errors.full_messages.join('; ') if user_errors.present?
			return false
		else
			self.reviewer = user
		end
		true
	end
	
	# def validate_rating
	# 	unless rating.valid?
	# 		if rating.errors.present?
	# 			errors.add :rating, rating.errors.full_messages.join('; ')
	# 		else
	# 			errors.add :rating, I18n.t('activerecord.errors.review.attributes.rating.invalid')
	# 		end
	# 	end
	# 	true
	# end
end
