class UsersController < ApplicationController
	before_filter :authenticate_user!
	before_filter :set_up_user, except: [:index]
	load_and_authorize_resource
	
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
	
	private
	
	def set_up_user
		@user = current_user
		@user.build_profile unless @user.profile
		@profile = @user.profile
	end
end
