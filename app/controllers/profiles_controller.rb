class ProfilesController < ApplicationController
	before_filter :authenticate_user!
	
	# Side effect: loads @products or @product as appropriate.
	# e.g., for index action, @products is set to Product.accessible_by(current_ability)
	load_and_authorize_resource
	
	def create
		# @profile initialized by load_and_authorize_resource with cancan ability conditions and then parameter values.
		if @profile.save
			redirect_to profiles_path, notice: 'Profile was successfully created.' 
		else
			render action: "new"
		end
	end
end
