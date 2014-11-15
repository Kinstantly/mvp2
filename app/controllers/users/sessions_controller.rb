class Users::SessionsController < Devise::SessionsController
	layout :sessions_layout
	before_filter :verify_auth_token, :only => :create, if: -> { request.format.json? }

	private
	
	def sessions_layout
		['new', 'create'].include?(action_name) ? 'interior' : 'interior'
	end

	def verify_auth_token
		if params[:auth_token].blank? || params[:auth_token] != '7d04d7c4baa559fc49c03fe5fd8dd3c5'
			render nothing: true, status: 401
			return
		end
	end 
end
