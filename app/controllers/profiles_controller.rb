class ProfilesController < ApplicationController
	before_filter :authenticate_user!
	load_and_authorize_resource
	
	def index
		@profiles = Profile.all
	end

	def new
	end

	def edit
	end
end
