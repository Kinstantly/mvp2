class Users::SessionsController < Devise::SessionsController
	layout :sessions_layout
	
	private
	
	def sessions_layout
		['new', 'create'].include?(action_name) ? 'interior' : 'interior'
	end
end
