class StripeController < ApplicationController
	
	protect_from_forgery except: :webhook
	
	def webhook
		event = JSON.parse(request.body.read)
		logger.debug "event = #{event}" if Rails.env == 'development'
		logger.info "webhook: provider_id=>\"#{params[:provider_id]}\"; type=>\"#{event['type']}\"; user_id=>\"#{event['user_id']}\"; amount=>\"#{event['data']['object']['amount']}\"; "
		# response.status = 200
		render json: {}
	end
end
