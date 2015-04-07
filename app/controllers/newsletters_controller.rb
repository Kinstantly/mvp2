class NewslettersController < ApplicationController
	
	respond_to :html

	# GET /latest/:name
	def latest
		name = params[:name]
		list_name = list_name(name)
		url = latest_archive_url(list_name)
		url ||= default_sample_url(list_name)
		
		redirect_to url
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

	def latest_archive_url(list_name)
		gb = Gibbon::API.new
		gb.timeout = 2 # second(s)
		gb.throws_exceptions = false
		begin
			list_id = Rails.configuration.mailchimp_list_id[list_name]
			filters = { list_id: list_id, status: 'sent' }
			r = gb.campaigns.list filters: filters, sort_field: 'send_time', limit: 1
			if r.present? && r.try(:[], 'total').present? && r['total'] > 0
				url = r.try(:[], 'data').try(:[], 0).try(:[], 'archive_url')
			else
				logger.info "Error while retrieving MailChimp newsletter urls: #{r}" if logger
			end
		rescue Exception => e
			logger.info "Error while retrieving MailChimp newsletter urls: #{e.message}" if logger
		ensure
			return url
		end
	end
end
