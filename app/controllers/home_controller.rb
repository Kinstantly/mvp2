class HomeController < ApplicationController
	before_filter :authorize_admin, only: [:admin]
	# before_filter :authenticate_user!
	
	def index
		render layout: 'application'
	end
	
	private
	
	def authorize_admin
		authenticate_user!
		authorize! :any, :admin
	end
end
