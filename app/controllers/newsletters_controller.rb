class NewslettersController < ApplicationController
	
	respond_to :html

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
end
