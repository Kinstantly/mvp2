module EmailDeliveriesHelper
	
	def generic_email_delivery_info(delivery)
		t 'views.email_delivery.view.info', recipient: delivery.recipient, time: display_profile_time(delivery.created_at), sender: delivery.sender
	end
	
end
