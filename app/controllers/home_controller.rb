class HomeController < ApplicationController
	# before_filter :authenticate_user!
	# layout 'no_user_registration'
	layout false, only: :index
	
	def index
		render handlers: [:erb]
	end
end
