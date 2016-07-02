class HomeController < ApplicationController
	before_action :authenticate_user_on_private_site, except: [:about, :contact, :privacy, :terms]
	before_action :authenticate_user_on_public_site, only: [:admin]
	before_action :authorize_admin, only: [:admin]
	# before_action :authenticate_user!
	
	def index
		case params[:version]
		when 'old'
			render action: 'index_old', layout: 'application'
		else
			render layout: 'application'
		end
	end
	
	def admin
		render layout: 'plain'
	end

	def blog
		redirect_to blog_url
	end
	
	private
	
	def authorize_admin
		authorize! :any, :admin
	end
end
