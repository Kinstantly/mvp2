class Users::RegistrationsController < Devise::RegistrationsController
	# Add this controller to the devise route if you need to customize the registration controller.
	
	# after_filter :after_registration, :only => [:create], :if => "resource.errors.empty?"

	private

	def after_registration
		# resource.add_role :expert
		# resource.save!
	end
end
