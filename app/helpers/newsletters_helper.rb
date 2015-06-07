module NewslettersHelper
	def format_newsletter_date(date)
		date.strftime('%B %d, %Y') rescue Time.zone.now.strftime('%B %d, %Y')
	end
	
	def newsletter_link_text(newsletter)
		"#{format_newsletter_date newsletter.send_time}: #{newsletter.subject}"
	end
end
