module StripeProcessing
	class Base
		include SiteConfigurationHelpers
		
		def initialize(logger=Rails.logger)
			@logger = logger
		end
		
		def call(params)
			process(params)
		rescue ActiveRecord::RecordNotFound => error
			@logger.error "#{self.class} Error: #{error}"
		end
		
		private
		
		def log_event(wrapper)
			user_id = wrapper[:user_id]
			if (event = wrapper[:event])
				data = event.data
				object = data.try :[], 'object'
				@logger.info "#{self.class}: livemode=>\"#{event.livemode}\", type=>\"#{event.type}\", user_id=>\"#{user_id}\", object['id']=>\"#{object.try :[], 'id'}\", object['customer']=>\"#{object.try :[], 'customer'}\", object['amount']=>\"#{object.try :[], 'amount'}\""
			elsif wrapper[:type] == 'ignore'
				@logger.info "#{self.class}: ignoring event for livemode=>\"#{wrapper[:livemode]}\", type=>\"#{wrapper[:event_type]}\", id=>\"#{wrapper[:id]}\", user_id=>\"#{user_id}\""
			else
				@logger.error "#{self.class}: could not retrieve event for type=>\"#{wrapper[:type]}\", user_id=>\"#{user_id}\""
			end
		end
		
		def stripe_info(wrapper)
			StripeInfo.find_by_stripe_user_id!(wrapper[:user_id])
		end
		
		def data_object(wrapper)
			wrapper[:event].data[:object]
		end
		
		def first_or_create_customer(wrapper)
			livemode = wrapper[:livemode]
			obj = data_object(wrapper)
			stripe_info(wrapper).stripe_customers.where(api_customer_id: obj[:id]).first_or_create!(livemode: livemode)
		end
		
		def find_customer(wrapper)
			stripe_info(wrapper).stripe_customers.find_by_api_customer_id!(data_object(wrapper)[:id])
		end
		
		def first_or_create_card(wrapper)
			livemode = wrapper[:livemode]
			obj = data_object(wrapper)
			card_id, customer_id = obj[:id], obj[:customer]
			stripe_info(wrapper).stripe_customers.find_by_api_customer_id!(customer_id).stripe_cards.where(api_card_id: card_id).first_or_create!(livemode: livemode)
		end
		
		def find_card(wrapper)
			obj = data_object(wrapper)
			card_id, customer_id = obj[:id], obj[:customer]
			 stripe_info(wrapper).stripe_customers.find_by_api_customer_id!(customer_id).stripe_cards.find_by_api_card_id!(card_id)
		end
		
		def first_or_create_charge(wrapper)
			livemode = wrapper[:livemode]
			obj = data_object(wrapper)
			charge_id, card_data = obj[:id], obj[:card]
			card_id, customer_id = card_data[:id], card_data[:customer]
			card = stripe_info(wrapper).stripe_customers.find_by_api_customer_id!(customer_id).stripe_cards.find_by_api_card_id!(card_id)
			card.stripe_charges.where(api_charge_id: charge_id).first_or_create!(livemode: livemode)
		end
	end
	
	# The description attribute is used to identify the creating app.
	class CustomerCreated < Base
		def process(wrapper)
			obj = data_object(wrapper)
			customer = first_or_create_customer(wrapper)
			customer.update_attributes!(description: obj[:description])
			@logger.info "#{self.class}: #{customer.inspect}"
		end
	end
	
	# Do not update the description! We are using it to identify the app that created this customer.
	class CustomerUpdated < Base
		def process(wrapper)
			customer = first_or_create_customer(wrapper)
			@logger.info "#{self.class}: #{customer.inspect}"
		end
	end
	
	class CustomerDeleted < Base
		def process(wrapper)
			customer = find_customer(wrapper)
			customer.update_attribute(:deleted, true)
			@logger.info "#{self.class}: #{customer.inspect}"
		end
	end
	
	class CustomerCardCreated < Base
		def process(wrapper)
			card = first_or_create_card(wrapper)
			@logger.info "#{self.class}: #{card.inspect}"
		end
	end
	
	class CustomerCardDeleted < Base
		def process(wrapper)
			card = find_card(wrapper)
			card.update_attribute(:deleted, true)
			@logger.info "#{self.class}: #{card.inspect}"
		end
	end
	
	class ChargeBase < Base
		def process(wrapper)
			obj = data_object(wrapper)
			charge = first_or_create_charge(wrapper)
			values = {
				amount: obj[:amount], paid: obj[:paid], captured: obj[:captured],
				amount_refunded: obj[:amount_refunded], refunded: obj[:refunded]
			}
			charge.update_attributes!(values)
			@logger.info "#{self.class}: #{charge.inspect}"
		end
	end
	
	class ChargeSucceeded < ChargeBase
	end
	
	class ChargeCaptured < ChargeBase
	end
	
	class ChargeUpdated < ChargeBase
	end
	
	class ChargeRefunded < ChargeBase
	end
	
	class EventLogger < Base
		def process(wrapper)
			log_event wrapper
		end
	end
	
	# Confirm the data sent to the web hook by retrieving the event from Stripe.  Return the event data retrieved from Stripe instead of the data sent to the web hook.
	# If we are live and the event is a test, ignore it.
	# If the sent data is corrupted, drop it.
	class EventRetriever < Base
		def process(params)
			event_id = params[:id]
			event_livemode = params[:livemode]
			user_id = params[:user_id]
			if stripe_live_mode? && !event_livemode
				{
					type: 'ignore',
					livemode: event_livemode,
					event_type: params[:type],
					id: event_id,
					user_id: user_id
				}
			elsif event_id =~ /\A\w+\z/ and user_id =~ /\A\w+\z/
				api_key = StripeInfo.find_by_stripe_user_id!(user_id).access_token
				event = Stripe::Event.retrieve(event_id, api_key)
				{
					type: event.type,
					livemode: event.livemode,
					user_id: user_id,
					event: event
				}
			else
				{}
			end
		end
	end
end
