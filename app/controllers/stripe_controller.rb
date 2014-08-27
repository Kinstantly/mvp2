class StripeController < ApplicationController
	
	protect_from_forgery except: :webhook
	
	def webhook
		event = JSON.parse(request.body.read)
		provider_id = params[:provider_id].try(:to_s)
		logger.debug "event=>#{event.to_s}" if Rails.env == 'development'
		if event.is_a?(Hash)
			type = event['type']
			msgs = []
			add_property msgs, 'provider_id', provider_id
			add_property msgs, 'type', type
			add_property msgs, 'user_id', event['user_id']
			data = event['data']
			object = data.try(:'[]', 'object')
			case type
			when 'charge.succeeded'
				add_property msgs, 'amount', object['amount']
				add_property msgs, 'customer', object['customer']
			when 'customer.created'
				add_property msgs, 'customer_id', object['id']
			end
			logger.info('Webhook: ' + msgs.join('; '))
		else
			logger.info "Webhook: provider_id=>\"#{provider_id}\"; event is a #{event.class}"
		end
		# response.status = 200
		render json: {}
	end
	
	private
	
	def add_property(messages, name, value)
		messages << "#{name}=>\"#{value}\""
	end
end
