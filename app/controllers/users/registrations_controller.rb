class Users::RegistrationsController < Devise::RegistrationsController

	after_filter :after_registration, :only => [:create], :if => "resource.errors.empty?"

	private

	def after_registration
		resource.add_role :expert
		resource.save!
	end
end
