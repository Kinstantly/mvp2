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
	
	def pro
		redirect_to provider_sell_page
	end
	
	def about
		redirect_to about_page
	end
	
	def contact
		redirect_to contact_page
	end
	
	def terms
		redirect_to terms_page
	end
	
	def privacy
		redirect_to privacy_page
	end
	
	private
	
	def authorize_admin
		authorize! :any, :admin
	end
end
