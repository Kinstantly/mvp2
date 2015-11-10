class HomeController < ApplicationController
	before_filter :authenticate_user_on_private_site, except: [:about, :contact, :privacy, :terms]
	before_filter :authenticate_user_on_public_site, only: [:admin]
	before_filter :authorize_admin, only: [:admin]
	# before_filter :authenticate_user!
	
	def index
		case params[:version]
		when 'a'
			@stylesheet_version = 'home_page_version_a'
			render action: 'index_version', layout: 'application'
		when 'b'
			@stylesheet_version = 'home_page_version_b'
			render action: 'index_version', layout: 'application'
		else
			render layout: 'application'
		end
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
