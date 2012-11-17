class ProfilesController < ApplicationController
	before_filter :authenticate_user!
	
	# Side effect: loads @profiles or @profile as appropriate.
	# e.g., for index action, @profiles is set to Profile.accessible_by(current_ability)
	load_and_authorize_resource
	
	# *After* profile is loaded, ensure it has at least one location.
	before_filter :require_location_in_profile, only: [:new, :edit]
	
	def create
		# @profile initialized by load_and_authorize_resource with cancan ability conditions and then parameter values.
		if @profile.save
			set_flash_message :notice, :profile_created
			redirect_to action: :index
		else
			set_flash_message :alert, :profile_create_error
			render action: :new
		end
	end
	
	def update
		if @profile.update_attributes(params[:profile])
			set_flash_message :notice, :profile_updated
			redirect_to action: :index
		else
			set_flash_message :alert, :profile_update_error
			render action: :edit
		end
	end
end
