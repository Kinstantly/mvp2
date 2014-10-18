MoneyRails.configure do |config|

	# set the default currency
	config.default_currency = :usd

	# always show the cents part
	config.no_cents_if_whole = false

end
