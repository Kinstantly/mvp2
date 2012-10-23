class ProfilesController < ApplicationController
	before_filter :authenticate_user!
	
	# Side effect: loads @products or @product as appropriate.
	# e.g., for index action, @products is set to Product.accessible_by(current_ability)
	load_and_authorize_resource
	
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
