class StripeController < ApplicationController
	
	protect_from_forgery except: :webhook
	
	def webhook
		event = JSON.parse(request.body.read)
		provider_id = params[:provider_id].try(:to_s)
		logger.debug "event = #{event.to_s}" if Rails.env == 'development'
		if not event.is_a?(Hash)
			logger.info "webhook: provider_id=>\"#{provider_id}\"; event is a #{event.class}"
		elsif provider_id == 'hank' and event['type'] == 'charge.succeeded'
			event.delete('id')
			event['data'].try(:'[]', 'object').try(:delete, 'id')
			event['data'].try(:'[]', 'object').try(:delete, 'card')
			event['data'].try(:'[]', 'object').try(:delete, 'balance_transaction')
			logger.info "webhook: provider_id=>\"#{provider_id}\"; event=>#{event.to_s}"
		else
			logger.info "webhook: provider_id=>\"#{provider_id}\"; event['type']=>#{event['type']}"
		end
		# response.status = 200
		render json: {}
	end
end
