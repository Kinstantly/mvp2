class HomeController < ApplicationController
	before_filter :authorize_admin, only: [:admin]
	# before_filter :authenticate_user!
	
	def index
		case params[:view]
		when 'erb'
			render handlers: [:erb], layout: false
		when 'haml'
			render handlers: [:haml], layout: false
		else
			render handlers: [:haml], layout: false
		end
	end
	
	private
	
	def authorize_admin
		authenticate_user!
		authorize! :any, :admin
	end
end
