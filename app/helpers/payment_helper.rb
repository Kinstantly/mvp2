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
		time_with_zone.in_time_zone('America/Los_Angeles').strftime('%b %-d, %Y')
	end
	
	def display_payment_card_summary(card)
		"#{card.brand} #{card.funding} #{[card.exp_month, card.exp_year].compact.join('/')}" if card
	end
end
