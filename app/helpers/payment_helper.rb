module PaymentHelper
	def display_currency_amount(amount)
		format('$%.2f', (amount / 100.0))
	end
end
