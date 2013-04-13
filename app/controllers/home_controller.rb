class HomeController < ApplicationController
	before_filter :authorize_admin, only: [:admin]
	# before_filter :authenticate_user!
	# layout 'no_user_registration'
	
	layout false, only: :index
	
	def index
		render handlers: [:erb]
	end
	
	private
	
	def authorize_admin
		authenticate_user!
		authorize! :any, :admin
	end
end
