module StripeProcessing
	class Base
		def initialize(logger=Rails.logger)
			@logger = logger
		end
		
		private
		
		def log_event(wrapper)
			user_id = wrapper[:user_id]
			if (event = wrapper[:event])
				data = event.data
				object = data.try :[], 'object'
				@logger.info "#{self.class}: livemode=>\"#{event.livemode}\", type=>\"#{event.type}\", user_id=>\"#{user_id}\", object['id']=>\"#{object.try :[], 'id'}\", object['customer']=>\"#{object.try :[], 'customer'}\", object['amount']=>\"#{object.try :[], 'amount'}\""
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
			obj = data_object(wrapper)
			stripe_info(wrapper).stripe_customers.where(api_customer_id: obj[:id]).first_or_create!
		end
		
		def find_customer(wrapper)
			stripe_info(wrapper).stripe_customers.find_by_api_customer_id!(data_object(wrapper)[:id])
		end
		
		def first_or_create_card(wrapper)
			obj = data_object(wrapper)
			card_id, customer_id = obj[:id], obj[:customer]
			stripe_info(wrapper).stripe_customers.find_by_api_customer_id!(customer_id).stripe_cards.where(api_card_id: card_id).first_or_create!
		end
		
		def find_card(wrapper)
			obj = data_object(wrapper)
			card_id, customer_id = obj[:id], obj[:customer]
			 stripe_info(wrapper).stripe_customers.find_by_api_customer_id!(customer_id).stripe_cards.find_by_api_card_id!(card_id)
		end
		
		def first_or_create_charge(wrapper)
			obj = data_object(wrapper)
			charge_id, card_data = obj[:id], obj[:card]
			card_id, customer_id = card_data[:id], card_data[:customer]
			card = stripe_info(wrapper).stripe_customers.find_by_api_customer_id!(customer_id).stripe_cards.find_by_api_card_id!(card_id)
			card.stripe_charges.where(api_charge_id: charge_id).first_or_create!
		end
	end
	
	class CustomerCreated < Base
		def call(wrapper)
			obj = data_object(wrapper)
			customer = first_or_create_customer(wrapper)
			customer.update_attributes!(description: obj[:description])
			@logger.info "#{self.class}: #{customer.inspect}"
		end
	end
	
	class CustomerUpdated < Base
		def call(wrapper)
			customer = first_or_create_customer(wrapper)
			@logger.info "#{self.class}: #{customer.inspect}"
		end
	end
	
	class CustomerDeleted < Base
		def call(wrapper)
			customer = find_customer(wrapper)
			customer.update_attribute(:deleted, true)
			@logger.info "#{self.class}: #{customer.inspect}"
		end
	end
	
	class CustomerCardCreated < Base
		def call(wrapper)
			card = first_or_create_card(wrapper)
			@logger.info "#{self.class}: #{card.inspect}"
		end
	end
	
	class CustomerCardDeleted < Base
		def call(wrapper)
			card = find_card(wrapper)
			card.update_attribute(:deleted, true)
			@logger.info "#{self.class}: #{card.inspect}"
		end
	end
	
	class ChargeSucceeded < Base
		def call(wrapper)
			obj = data_object(wrapper)
			charge = first_or_create_charge(wrapper)
			charge.update_attributes!(amount: obj[:amount], paid: obj[:paid], captured: obj[:captured])
			@logger.info "#{self.class}: #{charge.inspect}"
		end
	end
	
	class ChargeCaptured < ChargeSucceeded
	end
	
	class ChargeRefunded < Base
		def call(wrapper)
			obj = data_object(wrapper)
			charge = first_or_create_charge(wrapper)
			charge.update_attributes!(amount_refunded: obj[:amount_refunded], refunded: obj[:refunded])
			@logger.info "#{self.class}: #{charge.inspect}"
		end
	end
	
	class EventLogger < Base
		def call(wrapper)
			log_event wrapper
		end
	end
	
	class EventRetriever < Base
		def call(params)
			event_id = params[:id]
			user_id = params[:user_id]
			if event_id =~ /\A\w+\z/ and user_id =~ /\A\w+\z/
				api_key = StripeInfo.find_by_stripe_user_id!(user_id).access_token
				event = Stripe::Event.retrieve(event_id, api_key)
				{
					type: event.type,
					user_id: user_id,
					event: event
				}
			else
				{}
			end
		rescue ActiveRecord::RecordNotFound => error
			@logger.error "#{self.class}: #{error}"
		end
	end
end
