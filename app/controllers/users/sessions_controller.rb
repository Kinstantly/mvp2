class Users::SessionsController < Devise::SessionsController
	layout :sessions_layout
	
	private
	
	def sessions_layout
		['new', 'create'].include?(action_name) ? 'interior_no_top_nav' : 'interior'
	end
end
