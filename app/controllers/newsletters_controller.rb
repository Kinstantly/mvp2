class NewslettersController < ApplicationController
	
	respond_to :html
	
	before_filter :load_variables

	# GET /newsletter
	def new
		if @subscribing_to_alerts or @subscribing_to_oldnewsletters
			render layout: 'interior'
		else
			redirect_to alerts_url
		end
	end

	# POST /newsletters/subscribe
	def subscribe
		@errors = []
		@email = params[:email].presence
		@duebirth1 = params[:duebirth1].presence
		
		active_mailing_lists.each do |list|
			instance_variable_set "@#{list}", params[list].present?
		end

		subscribe_lists = active_mailing_lists.select do |list|
			instance_variable_get "@#{list}"
		end

		@errors << t('views.newsletter.email_required') if @email.blank?
		@errors << t('views.newsletter.list_required') if subscribe_lists.blank?
		@errors << t('views.newsletter.bad_date_format', input_format: input_date_format_string) if @duebirth1 && @duebirth1 !~ input_date_regexp && @duebirth1 !~ iso_date_regexp

		if @errors.any?
			render :new
		else
			subscribe_options = { subscribing_to_alerts: @subscribing_to_alerts }
			subscribe_options[:merge_vars] = { 'DUEBIRTH1' => @duebirth1 } if @duebirth1
			job = NewsletterSubscriptionJob.new subscribe_lists, @email, subscribe_options
			if update_mailing_lists_in_background?
				Delayed::Job.enqueue job
			else
				job.perform
			end
			subscribed_url_params = subscribe_lists.inject(nlsub: 't'){ |p, list| p.merge list => 't' }
			if @subscribing_to_alerts
				redirect_to alerts_subscribed_url(subscribed_url_params)
			else
				redirect_to newsletters_subscribed_url(subscribed_url_params)
			end
		end
	end

	# GET /newsletters/subscribed
	def subscribed
		render :subscribed, layout: 'interior'
	end

	# GET /latest/:name
	def latest
		name = params[:name]
		@newsletter = case name
			when "parent_newsletters_stage2"
				Newsletter.parent_newsletters_stage2.last_sent
			when "parent_newsletters_stage3"
				Newsletter.parent_newsletters_stage3.last_sent
			else
				Newsletter.parent_newsletters_stage1.last_sent
			end
		@styles = false
		set_seo_elements @newsletter
		render :show, layout: 'iframe_layout'
	end

	# GET /list/:name, where :name is optional
	def list
		name = params[:name]
		list_name = list_name(name)
		@stage1_newsletters = Newsletter.parent_newsletters_stage1.order_by_send_time
		@stage2_newsletters = Newsletter.parent_newsletters_stage2.order_by_send_time
		@stage3_newsletters = Newsletter.parent_newsletters_stage3.order_by_send_time
		@meta_description = "#{t 'views.newsletter.archive'} - #{t 'views.newsletter.name'}"
		@meta_keywords = "#{t 'views.newsletter.archive'} #{t 'views.newsletter.name'}".downcase
	end

	# GET /list/:id
	def show
		id = params[:id]
		@styles = false
		@newsletter = Newsletter.find_by_cid(id)
		set_seo_elements @newsletter
		render layout: 'iframe_layout'
	end

	# Class method to create a new MailChimp subscription.
	def self.subscribe_to_mailing_lists(lists, email, options={})
		successful_subscribes = []
		lists.each do |list_name|
			next if !User.mailing_list_name_valid?(list_name)

			list_id = mailchimp_list_ids[list_name]
			email_struct = { email: email }
			begin
				gb = Gibbon::API.new
				subscribe_params = {
					id: list_id,
					email: email_struct,
					double_optin: false,
					send_welcome: send_mailchimp_welcome?
				}
				subscribe_params[:merge_vars] = options[:merge_vars] if options[:merge_vars]
				r = gb.lists.subscribe subscribe_params
				if r.try(:[], 'leid').present?
					successful_subscribes << list_name
				end
			rescue Gibbon::MailChimpError => e
				logger.error "MailChimp error while subscribing guest user with email #{email_struct} to #{list_name}: #{e.message}, error code: #{e.code}" if logger
			end
		end
		if successful_subscribes.any?
			if options[:subscribing_to_alerts]
				AdminMailer.alerts_subscribe_alert(successful_subscribes, email, options).deliver_now
			else
				AdminMailer.newsletter_subscribe_alert(successful_subscribes, email).deliver_now
			end
		end
	end
	
	private
	
	def load_variables
		@subscribing_to_alerts = params[:alerts].present?
		@subscribing_to_oldnewsletters = params[:oldnewsletters].present?
	end

	def list_name(name_str)
		case name_str
		when "parent_newsletters_stage1"
			list_name = :parent_newsletters_stage1
		when "parent_newsletters_stage2"
		 	list_name = :parent_newsletters_stage2
		when "parent_newsletters_stage3"
		 	list_name = :parent_newsletters_stage3
		end
		list_name
	end

	def default_sample_url(list_name)
		case list_name
		when :parent_newsletters_stage1
			url = "http://us9.campaign-archive1.com/?u=9da2f83266d2dfd9641ba63f6&id=6d7f820f78"
		when :parent_newsletters_stage2
			url = "http://us9.campaign-archive1.com/?u=9da2f83266d2dfd9641ba63f6&id=2d58b8e01a"
		when :parent_newsletters_stage3
			url = "http://us9.campaign-archive1.com/?u=9da2f83266d2dfd9641ba63f6&id=272d9c40d2"
		else
			url = "#"
		end
		url
	end

	def archive_url(id)
		gb = Gibbon::API.new
		begin
			r = gb.campaigns.list filters: { id: id }
			url = r.try(:[], 'data').try(:[], 0).try(:[], 'archive_url') unless r.blank?
		rescue Exception => e
			logger.info "Error while retrieving MailChimp newsletter ##{id}: #{e.message}" if logger
		ensure
			return url
		end
	end

	def latest_archive_url(list_name)
		gb = Gibbon::API.new
		gb.timeout = 2 # second(s)
		begin
			list_id = mailchimp_list_ids[list_name]
			filters = { list_id: list_id, status: 'sent' }
			r = gb.campaigns.list filters: filters, sort_field: 'send_time', limit: 1
			url = r.try(:[], 'data').try(:[], 0).try(:[], 'archive_url') unless r.blank?
		rescue Exception => e
			logger.info "Error while retrieving MailChimp newsletter urls: #{e.message}" if logger
		ensure
			return url
		end
	end

	def list_archive(list_name)
		gb = Gibbon::API.new
		begin
			list_id = mailchimp_list_ids[list_name]
			filters = { list_id: list_id, status: 'sent' }
			r = gb.campaigns.list filters: filters, sort_field: 'send_time', limit: 100
			data = r.try(:[], 'data') unless r.blank?
		rescue Exception => e
			logger.info "Error while retrieving MailChimp newsletter urls: #{e.message}" if logger
		ensure
			return data || []
		end
	end
	
	# Set instance variables used to populate SEO elements, e.g., meta description and keywords.
	def set_seo_elements(newsletter)
		if newsletter
			@meta_description = "#{t 'views.newsletter.name'} - #{newsletter.subject} - Sent #{newsletter.send_time}"
			@meta_keywords = newsletter.subject.downcase
		end
	end
	
	# Set exceptions to default values of the security-related HTTP headers in the response.
	# See https://www.owasp.org/index.php/List_of_useful_HTTP_headers
	# http://tools.ietf.org/html/rfc7034
	# http://www.w3.org/TR/CSP/#directive-frame-ancestors
	def set_default_response_headers
		super
		if response && ['latest', 'show'].include?(action_name)
			response.headers.merge!({
				'Content-Security-Policy' => "frame-ancestors 'self'",
				'X-Frame-Options' => 'SAMEORIGIN'
			})
		end
	end
end
