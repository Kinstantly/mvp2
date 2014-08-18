class StripeController < ApplicationController
	
	protect_from_forgery except: :webhook
	
	def webhook
		event = JSON.parse(request.body.read)
		provider_id = params[:provider_id]
		logger.debug "event = #{event}" if Rails.env == 'development'
		if provider_id == 'hank'
			logger.info "webhook: provider_id=>\"#{provider_id}\"; type=>\"#{event['type']}\"; user_id=>\"#{event['user_id']}\"; amount=>\"#{event['data']['object']['amount']}\""
		else
			logger.info "webhook: provider_id=>\"#{provider_id}\"; price=>\"#{event['price']}\"; custom=>\"#{event['custom']}\""
		end
		# response.status = 200
		render json: {}
	end
end
