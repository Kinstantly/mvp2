module PaymentHelper
	def display_currency_amount(amount)
		case amount
		when Money
			humanized_money_with_symbol(amount)
		when Fixnum
			format('$%.2f', (amount / 100.0))
		when NilClass
			'$0.00'
		else
			amount.to_s
		end
	end
	
	# Default to the 'America/Los_Angeles' time zone.
	# To do: ask the user for their time zone or detect it via Javascript.
	# https://github.com/scottwater/jquery.detect_timezone
	# https://bitbucket.org/pellepim/jstimezonedetect
	def display_transaction_date(time_with_zone)
		time_with_zone.in_time_zone('America/Los_Angeles').strftime('%b %-d, %Y') if time_with_zone
	end
	
	# Card brand, type, and expiration date.
	# Don't show the last four digits in email.
	def display_payment_card_in_email(card)
		"#{card.brand} #{card.funding} #{[card.exp_month, card.exp_year].compact.join('/')}" if card
	end
	
	# Card brand, last four digits, and expiration date.
	def display_payment_card_summary(card)
		which_card = card.last4.present? ? "#{t 'views.customer.view.card_last4'} #{card.last4}" : card.funding
		"#{card.brand} #{which_card}, #{t 'views.customer.view.card_exp'} #{[card.exp_month, card.exp_year].compact.join('/')}" if card
	end
	
	# Returns the path for the Stripe Connect button that the specified user can click to authorize payments to themselves.
	# Uses the redirect_uri parameter, so be sure to specify the callback URLs for each of the development/test, staging, and production environments.  They are specified via the Stripe web interface for the account that owns our app.
	# The default value of the stripe_landing parameter is configured in config/initializers/devise.rb.
	def stripe_connect_path_for(user)
		parameters = {
			redirect_uri: user_omniauth_callback_url(:stripe_connect)
		}
		if user
			parameters.merge!({
				'stripe_user[email]' => user.email,
				'stripe_user[country]' => default_profile_country,
				'stripe_user[currency]' => 'usd',
				'stripe_user[business_type]' => 'sole_prop',
				'stripe_user[physical_product]' => 'false'
			})
			if (profile = user.profile)
				parameters['stripe_user[url]'] = profile_url(profile)
				parameters['stripe_user[business_name]'] = profile.company_name if profile.company_name.present?
				parameters['stripe_user[first_name]'] = profile.first_name if profile.first_name.present?
				parameters['stripe_user[last_name]'] = profile.last_name if profile.last_name.present?
				if (location = profile.sorted_locations_with_addresses.first)
					parameters['stripe_user[street_address]'] = location.street_address if location.street_address.present?
					parameters['stripe_user[city]'] = location.city if location.city.present?
					parameters['stripe_user[state]'] = location.region if location.region.present?
					parameters['stripe_user[zip]'] = location.postal_code if location.postal_code.present?
					parameters['stripe_user[country]'] = location.country if location.country.present?
				end
				phone = profile.sorted_locations_with_phones.first.try(:phone)
				if phone.present? && (parsed_phone = Phonie::Phone.parse(phone))
					parameters['stripe_user[phone_number]'] = parsed_phone.format('%a%f%l')
				end
			end
		end
		user_omniauth_authorize_path :stripe_connect, parameters
	end
end
