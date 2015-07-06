class HomeController < ApplicationController
	before_filter :authenticate_user_on_private_site, except: [:about, :contact, :privacy, :terms]
	before_filter :authenticate_user_on_public_site, only: [:admin]
	before_filter :authorize_admin, only: [:admin]
	# before_filter :authenticate_user!
	
	def index
		render layout: 'application'
	end
	
	def admin
		render layout: 'plain'
	end

	def blog
		logger.debug "/blog path requested. Redirecting to http://blog.kinstantly.com" if logger
		redirect_to "http://blog.kinstantly.com"
	end
	
	private
	
	def authorize_admin
		authorize! :any, :admin
	end
end
