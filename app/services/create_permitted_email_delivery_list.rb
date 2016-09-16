class CreatePermittedEmailDeliveryList
	
	include SiteConfigurationHelpers
	
	attr_reader :params, :email_deliveries, :errors, :recipients, :blocked_recipients
	
	def initialize(params)
		@params = params
		@email_deliveries = []
		@errors = []
	end
	
	def call
		if params[:email_list].empty?
			@errors << I18n.t('views.email_delivery.edit.email_list_empty_error')
			return (@successful = false)
		end
		@successful = true
		@recipients, @blocked_recipients = separate_blocked_recipients(parse_email_list_string(params[:email_list]))
		@email_deliveries = @recipients.map do |email|
			email_delivery = EmailDelivery.create({
				recipient: email,
				sender: params[:sender],
				email_type: params[:email_type],
				token: EmailDelivery.generate_token
			})
			if email_delivery.errors.present?
				@successful = false
				email_delivery.errors.each do |attribute, error|
					@errors << if attribute == :recipient
						"'#{email_delivery.recipient}' #{error}"
					else
						"#{EmailDelivery.human_attribute_name attribute} #{error}"
					end
				end
			end
			email_delivery
		end
		@successful
	end
	
	def email_unsubscribe_list_string
		@email_deliveries.map do |email_delivery|
			unsubscribe_url = Rails.application.routes.url_helpers.new_contact_blocker_from_email_delivery_url email_delivery_token: email_delivery.token, host: default_host
			"#{email_delivery.recipient}\t#{unsubscribe_url}"
		end.join("\n")
	end
	
	def successful?
		@successful
	end
	
	def destroy
		@email_deliveries.map &:destroy
	end
	
	private
	
	def parse_email_list_string(s)
		s.present? ? s.downcase.strip.split(/\s*[\n,;]\s*/) : []
	end
	
	def separate_blocked_recipients(recipients)
		blocked = []
		if recipients.present?
			blocked = ContactBlocker.where('LOWER(email) IN (?)', recipients).map(&:email)
		end
		[recipients - blocked, blocked]
	end
end
