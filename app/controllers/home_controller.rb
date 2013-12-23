class HomeController < ApplicationController
	before_filter :authorize_admin, only: [:admin]
	# before_filter :authenticate_user!
	
	caches_action :show_all_categories, layout: false
	
	def index
		render layout: 'application'
	end
	
	def admin
		render layout: 'plain'
	end
	
	private
	
	def authorize_admin
		authenticate_user!
		authorize! :any, :admin
	end
end
