class UsersController < ApplicationController
	before_filter :authenticate_user!
	before_filter :set_up_user, except: [:index, :claim_profile]
	load_and_authorize_resource
	before_filter :process_profile_publish_param, only: [:update_profile]
	
	# *After* profile is loaded, ensure it has at least one location.
	before_filter :require_location_in_profile, only: [:edit_profile]
	
	def index
		@users = User.all
	end
	
	def view_profile
	end
	
	def edit_profile
	end
	
	def update_profile
		if @user.update_attributes(params[:user])
			set_flash_message :notice, :profile_updated
			redirect_to action: :view_profile
		else
			set_flash_message :alert, :profile_update_error
			render action: :edit_profile
		end
	end
	
	def claim_profile
		user = current_user
		token = params[:token]
		if user.is_provider? && user.profile.nil? && token.present? &&
			(profile = Profile.find_by_invitation_token(token)) && profile.user.nil? &&
			(user.profile = profile) && user.save
			set_flash_message :notice, :profile_claimed
			redirect_to action: :view_profile
		else
			set_flash_message :alert, :profile_claim_error
			redirect_to root_path
		end
	end
	
	private
	
	def set_up_user
		@user = current_user
		if @user.is_provider?
			@user.build_profile unless @user.profile
			@profile = @user.profile
		end
	end
end
