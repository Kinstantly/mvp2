class UsersController < ApplicationController
	before_filter :authenticate_user!
	before_filter :set_up_user
	
	def edit_profile
		@user.build_profile unless @user.profile
	end
	
	def update_profile
		if @user.update_attributes(params[:user])
			set_flash_message :notice, :profile_saved
			redirect_to action: :edit_profile
		else
			set_flash_message :alert, :profile_update_error
			render action: :edit_profile
		end
	end
	
	private
	
	def set_up_user
		@user = current_user
	end
end
