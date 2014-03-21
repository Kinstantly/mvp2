class UsersController < ApplicationController
	layout 'plain'
	
	before_filter :authenticate_user!
	before_filter :set_up_user, only: [:view_profile, :update_profile, :edit_profile]
	load_and_authorize_resource
	before_filter :process_profile_admin_params, only: [:update_profile]
	
	# *After* profile is loaded, ensure it has at least one location.
	before_filter :require_location_in_profile, only: [:edit_profile]
	
	def index
		@order_by_options = { recent: 'recent', email: 'email' }
		case params[:order_by]
		when 'recent'
			@users = @users.order_by_descending_id
		when 'email'
			@users = @users.order_by_email
		else
			@users = @users.order_by_id
		end
		@users = @users.page(params[:page]).per(params[:per_page])
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
	
	# Try to claim the profile specified by the token parameter.
	# Do not use set_up_user filter because we don't want to build a profile.
	def claim_profile
		if current_user.has_persisted_profile? && !@force_claim_profile
			set_flash_message :alert, :already_has_profile
			redirect_to confirm_claim_profile_url(claim_token: params[:token])
		elsif current_user.claim_profile(params[:token], @force_claim_profile)
			set_flash_message :notice, :profile_claimed
			redirect_to my_profile_url
		else
			set_flash_message :alert, :profile_claim_error
			redirect_to root_url
		end
	end
	
	# Claim the profile specified by the token parameter even if we already have a profile.
	# Do not use set_up_user filter because we don't want to build a profile.
	def force_claim_profile
		@force_claim_profile = true
		claim_profile
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
