class Newsletter < ActiveRecord::Base
	has_paper_trail # Track changes to each rating.
	
	attr_accessible :cid, :list_id, :send_time, :title, :subject, :archive_url, :content
	validates_presence_of :cid, :list_id, :send_time, :title, :subject, :archive_url, :content
	
	scope :parent_newsletters_stage1, -> { where(list_id: Rails.configuration.mailchimp_list_id[:parent_newsletters_stage1]) }
	scope :parent_newsletters_stage2, -> { where(list_id: Rails.configuration.mailchimp_list_id[:parent_newsletters_stage2]) }
	scope :parent_newsletters_stage3, -> { where(list_id: Rails.configuration.mailchimp_list_id[:parent_newsletters_stage3]) }
	
	def self.order_by_send_time
		order('send_time desc')
	end
	
	def self.last_updated
		order(:updated_at).last
	end
end
