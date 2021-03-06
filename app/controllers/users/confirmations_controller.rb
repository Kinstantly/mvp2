class Users::ConfirmationsController < Devise::ConfirmationsController
	
	before_action :set_admin_mode
	
	# GET /resource/confirmation?confirmation_token=abcdef
	def show
		super do |resource|
			sign_in(resource_name, resource) if resource.errors.empty?
		end
	end
	
	protected
	
	# The path used after resending confirmation instructions.
	def after_resending_confirmation_instructions_path_for(resource_name)
		if current_user.try :admin?
			set_flash_message :notice, :admin_sent_instructions
			user_path resource
		else
			super
		end
	end

	# The path used after confirmation.
	def after_confirmation_path_for(resource_name, resource)
		path_or_url = if session[:after_confirmation_url].present?
			session.delete :after_confirmation_url
		elsif resource.try(:signed_up_from_blog)
			blog_url
		elsif resource.try(:is_provider?)
			edit_my_profile_path
		else
			stored_location_for(resource) || super
		end
		# Add various flags for tracking purposes.
		path_or_url += (path_or_url.include?(??) ? '&' : '?') + 'email_confirmed=t'
		if resource
			path_or_url += '&nlsub=t' if resource.signed_up_for_mailing_lists
			path_or_url += '&blog=t' if resource.signed_up_from_blog
			active_mailing_lists.each do |list|
				path_or_url += "&#{list}=t" if resource.send list
			end
		end
		path_or_url
	end
	
	private
	
	def set_admin_mode
		if current_user.try :admin?
			resource_params.permit :email, :admin_confirmation_sent_by_id
		end
	end
	
end
