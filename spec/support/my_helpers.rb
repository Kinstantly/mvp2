RSpec.configure do |config|
	config.include PaymentHelper, :type => :view
	config.include MoneyRails::ActionViewExtension, :type => :view
end
