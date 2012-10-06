class HomeController < ApplicationController
	# before_filter :authenticate_user!
	layout 'no_top_nav', only: [:request_expert, :become_expert]

	def index
	end
end
