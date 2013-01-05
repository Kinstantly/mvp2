class ProfilesController < ApplicationController
	before_filter :authenticate_user!, except: [:index, :show, :link_index, :search]
	
	# Side effect: loads @profiles or @profile as appropriate.
	# e.g., for index action, @profiles is set to Profile.accessible_by(current_ability)
	load_and_authorize_resource
	skip_load_and_authorize_resource only: :search
	
	# *After* profile is loaded:
	#   ensure it has at least one location
	#   set publish state based on parameter
	before_filter :require_location_in_profile, only: [:new, :edit]
	before_filter :process_profile_publish_param, only: [:create, :update]
	
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
	
	def search
		@search = Profile.fuzzy_search params[:query], !current_user.try(:profile_editor?)
		render :search_results
	end
end
