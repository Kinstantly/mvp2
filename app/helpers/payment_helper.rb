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
	
	def display_transaction_date(time_with_zone)
		time_with_zone.localtime.strftime('%b %-d, %Y')
	end
	
	def display_payment_card_summary(card)
		"#{card.brand} #{card.funding} #{[card.exp_month, card.exp_year].compact.join('/')}" if card
	end
end
