class Users::SessionsController < Devise::SessionsController
	layout :sessions_layout

	respond_to :json, only: :create
	before_action :verify_auth_token, :only => :create, if: -> { request.format.json? }

	private
	
	def sessions_layout
		['new', 'create'].include?(action_name) ? 'interior' : 'interior'
	end

	def verify_auth_token
		if params[:auth_token].blank? || params[:auth_token] != Rails.configuration.sign_in_auth_token
			render nothing: true, status: 401
			return
		end
	end 
end
