# Rack middleware configuration for blocking & throttling abusive requests.
# https://github.com/kickstarter/rack-attack
# https://github.com/kickstarter/rack-attack/wiki/Example-Configuration
class Rack::Attack
	# To dynamically block an IP address do this from the console:
	# > Rails.cache.write 'deny_request_from_ip_address_1.2.3.4', true, expires_in: 5.days
	# To remove the block:
	# > Rails.cache.delete 'deny_request_from_ip_address_1.2.3.4'
	# You can also block a class C network:
	# > Rails.cache.write 'deny_request_from_ip_address_1.2.3', true, expires_in: 5.days
	blacklist('deny request from IP address') do |request|
		key = "deny_request_from_ip_address_#{request.ip}"
		Rails.cache.fetch(key).present? or Rails.cache.fetch(key.sub(/\.\d+\z/, '')).present?
	end
end
