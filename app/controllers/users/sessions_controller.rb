class Users::SessionsController < Devise::SessionsController
	layout 'interior_no_top_nav', only: [:new, :create]
end
