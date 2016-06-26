namespace :kinstantly_stripe do
	desc 'Stripe will drop support for TLS 1.0 and 1.1 on July 1, 2016. Determine whether or not our Ruby integration supports TLS 1.2.'
	task test_tls: :environment do
		Stripe.api_key = "sk_test_BQokikJOvBiI2HlWgH4olfQ2"
		Stripe.api_base = "https://api-tls12.stripe.com"

		begin
			Stripe::Charge.all()
			puts "TLS 1.2 supported, no action required."
		rescue OpenSSL::SSL::SSLError, Stripe::APIConnectionError
			puts "TLS 1.2 is not supported. You will need to upgrade your integration."
		end
	end

end
