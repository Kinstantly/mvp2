RSpec.configure do |config|
	config.include PaymentHelper, :type => :view
	config.include MoneyRails::ActionViewExtension, :type => :view
	config.include PaymentHelper, :type => :mailer
	config.include MoneyRails::ActionViewExtension, :type => :mailer
end
