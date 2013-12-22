class ReviewsController < ApplicationController
	
	respond_to :html, :js
	
	before_filter :authenticate_user!
	
	# Side effect: loads @reviews or @review as appropriate.
	# e.g., for index action, @reviews is set to Review.accessible_by(current_ability)
	# For actions specified by the :new option, a new review will be built rather than fetching one.
	load_and_authorize_resource new: :admin_create
	
	before_filter :load_profile, only: :new
	
	def admin_create
		# @review initialized with parameter values by load_and_authorize_resource.
		@success = @review.save_with_reviewer && @review.rate(params[:rating_score])
		respond_with @review, layout: false
	end
	
	def admin_update
		@success = @review.update_attributes_with_reviewer(params[:review]) && @review.rate(params[:rating_score])
		respond_with @review, layout: false
	end
	
	def destroy
		@review.destroy
		set_flash_message :notice, :destroyed
		redirect_to profile_path(@review.profile)
	end

	def create
 		@review.reviewer = @current_user
		success = @review.save_with_reviewer
		if success
			redirect_to profile_path @review.profile_id
		else
			respond_with @review, layout: false
		end
	end
	
	private
	
	def load_profile
		if (id = params[:profile_id]).present?
			@profile = Profile.accessible_by(current_ability, :show).find(id)
			@review[:profile_id] = @profile[:id]
		end
	end
end
