Stripe.api_key = ENV['STRIPE_SECRET_KEY'].presence || 'sk_test_AAv7llm8N32E7HErvRqgvjm6'

StripeEvent.event_retriever = StripeProcessing::EventRetriever.new

StripeEvent.configure do |events|
	events.all StripeProcessing::EventLogger.new
	events.subscribe 'customer.created', StripeProcessing::CustomerCreated.new
	events.subscribe 'customer.updated', StripeProcessing::CustomerUpdated.new
	events.subscribe 'customer.deleted', StripeProcessing::CustomerDeleted.new
	events.subscribe 'customer.card.created', StripeProcessing::CustomerCardCreated.new
	events.subscribe 'customer.card.deleted', StripeProcessing::CustomerCardDeleted.new
	events.subscribe 'charge.succeeded', StripeProcessing::ChargeSucceeded.new
	events.subscribe 'charge.captured', StripeProcessing::ChargeCaptured.new
	events.subscribe 'charge.updated', StripeProcessing::ChargeUpdated.new
	events.subscribe 'charge.refunded', StripeProcessing::ChargeRefunded.new
end
