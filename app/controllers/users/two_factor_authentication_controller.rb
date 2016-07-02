class Users::TwoFactorAuthenticationController < Devise::TwoFactorAuthenticationController
	before_action :prepare_for_update, only: :update

	def qrcode
		account = "#{default_host}/#{resource.email}"
		respond_to do |format|
			format.svg  { render qrcode: resource.provisioning_uri(account), unit: 4 }
		end
		# This code is sensitive -- never cache it!
		response.headers.merge!({
			'Cache-Control' => 'no-cache'
		}) if response
	end

	def reset_code
		resource.reset_otp_secret_key
		resource.save
		respond_to do |format|
			format.html  { render layout: false }
		end
	end
	
	private

	def prepare_for_update
		# Using otp_code in the form allows us to more precisely filter this parameter out of the log files.
		params[:code] = params[:otp_code]
	end 
end
