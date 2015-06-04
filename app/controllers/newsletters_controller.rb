class NewslettersController < ApplicationController
	
	respond_to :html

	# GET /newsletter
	def new
		render layout: 'interior'
	end

	def subscribe
		@errors = []
		@email = params[:email].presence
		@parent_newsletters_stage1 = params[:parent_newsletters_stage1].present?
		@parent_newsletters_stage2 = params[:parent_newsletters_stage2].present?
		@parent_newsletters_stage3 = params[:parent_newsletters_stage3].present?

		subscribe_lists = { parent_newsletters_stage1: @parent_newsletters_stage1,
			parent_newsletters_stage2: @parent_newsletters_stage2,
			parent_newsletters_stage3: @parent_newsletters_stage3 }
		subscribe_lists = subscribe_lists.select{ |k,v| v }.keys

		@errors << 'Email address is required' if @email.blank?
		@errors << 'Select at least one edition' if subscribe_lists.blank?

		if @errors.any?
			render :new
		else
			if Rails.env.production?
				delay.subscribe_to_mailing_lists(subscribe_lists, @email)
			else
				subscribe_to_mailing_lists(subscribe_lists, @email)
			end
			render :subscribed, layout: 'interior'
		end
	end

	# GET /latest/:name
	def latest
		name = params[:name]
		case name
		when "parent_newsletters_stage2"
			@newsletter_html = Newsletter.parent_newsletters_stage2.last_sent.try(:content)
		when "parent_newsletters_stage3"
			@newsletter_html = Newsletter.parent_newsletters_stage3.last_sent.try(:content)
		else
			@newsletter_html = Newsletter.parent_newsletters_stage1.last_sent.try(:content)
		end
		@styles = false
		render :show, layout: 'iframe_layout'
	end

	# GET /list/:name, where :name is optional
	def list
		name = params[:name]
		list_name = list_name(name)
		@stage1_newsletters = Newsletter.parent_newsletters_stage1.order_by_send_time
		@stage2_newsletters = Newsletter.parent_newsletters_stage2.order_by_send_time
		@stage3_newsletters = Newsletter.parent_newsletters_stage3.order_by_send_time
	end

	# GET /list/:id
	def show
		id = params[:id]
		@styles = false
		@newsletter_html = Newsletter.find_by_cid(id).try(:content)
		render layout: 'iframe_layout'
	end
	
	private

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
			list_id = Rails.configuration.mailchimp_list_id[list_name]
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
			list_id = Rails.configuration.mailchimp_list_id[list_name]
			filters = { list_id: list_id, status: 'sent' }
			r = gb.campaigns.list filters: filters, sort_field: 'send_time', limit: 100
			data = r.try(:[], 'data') unless r.blank?
		rescue Exception => e
			logger.info "Error while retrieving MailChimp newsletter urls: #{e.message}" if logger
		ensure
			return data || []
		end
	end

	# Creates new MailChimp subscription.
	def subscribe_to_mailing_lists(lists=[], email)
		lists.each do |list_name|
			next if !User.mailing_list_name_valid?(list_name)

			list_id = Rails.configuration.mailchimp_list_id[list_name]
			email_struct = { email: email }
			begin
				gb = Gibbon::API.new
				r = gb.lists.subscribe id: list_id, email: email_struct, double_optin: false
			rescue Gibbon::MailChimpError => e
				logger.error "MailChimp error while subscribing guest user with email #{email_struct} to #{list_name}: #{e.message}, error code: #{e.code}" if logger
			end
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
