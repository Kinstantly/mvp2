class Users::TwoFactorAuthenticationController < Devise::TwoFactorAuthenticationController
	before_filter :prepare_for_update, only: :update

	private

	def prepare_for_update
		# Using otp_code in the form allows us to more precisely filter this parameter out of the log files.
		params[:code] = params[:otp_code]
	end 
end
