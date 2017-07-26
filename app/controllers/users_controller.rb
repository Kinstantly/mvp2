class UsersController < ApplicationController
	layout 'plain'
	respond_to :js, only: [:update_profile_help, :formlet_update]

	before_action :authenticate_user!
	before_action :set_up_user, only: [:edit_subscriptions, :update_subscriptions, :view_profile, :update_profile, :edit_profile]
	load_and_authorize_resource
	
	# *After* profile is loaded, ensure it has at least one location.
	before_action :require_location_in_profile, only: [:edit_profile]
	
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

	def edit_subscriptions
		render layout: 'interior'
	end
	
	def update_subscriptions
		if @user.update_attributes(user_params)
			set_flash_message :notice, :subscriptions_updated
			redirect_to action: :edit_subscriptions
		else
			set_flash_message :alert, :subscriptions_update_error
			render action: :edit_subscriptions, layout: 'interior'
		end
	end

	# # DEPRECATED profile update via this controller.
	# def update_profile
	# 	if @user.update_attributes(params[:user], as: updater_role)
	# 		set_flash_message :notice, :profile_updated
	# 		redirect_to action: :view_profile
	# 	else
	# 		set_flash_message :alert, :profile_update_error
	# 		render action: :edit_profile
	# 	end
	# end
	
	# Try to claim the profile specified by the token parameter.
	# Do not use set_up_user filter because we don't want to build a profile.
	def claim_profile
		if current_user.has_persisted_profile? && !@force_claim_profile
			set_flash_message :alert, :already_has_profile
			redirect_to confirm_claim_profile_url(claim_profile_tracking_parameter.merge claim_token: params[:token])
		elsif current_user.claim_profile(params[:token], @force_claim_profile)
			# set_flash_message :notice, :profile_claimed
			redirect_to my_profile_url claim_profile_tracking_parameter
		else
			set_flash_message :alert, :profile_claim_error
			redirect_to root_url claim_profile_tracking_parameter
		end
	end
	
	# Claim the profile specified by the token parameter even if we already have a profile.
	# Do not use set_up_user filter because we don't want to build a profile.
	def force_claim_profile
		@force_claim_profile = true
		claim_profile
	end

	def update_profile_help
		params[:user].slice!(:profile_help)
		if current_user.update_attributes(user_params)
			@update_succeeded = true
		end
		render template: "profiles/profile_help_formlet_update"
	end
	
	def formlet_update
		@formlet = params[:formlet]
		if @formlet.blank? or "#{@formlet}" =~ /[.\/]/
			set_flash_message :alert, :update_error
		else
			@update_succeeded = @user.update_attributes(user_params)
		end
		respond_with @user, layout: false
	end

	private
	
	def set_up_user
		@user = current_user
		if @user.is_provider?
			@user.build_profile unless @user.profile
			@profile = @user.profile
		end
	end
	
	def user_params
		params.require(:user).permit(*User::PASSWORDLESS_ACCESSIBLE_ATTRIBUTES)
	end
end
