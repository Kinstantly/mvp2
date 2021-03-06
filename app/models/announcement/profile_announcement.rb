class ProfileAnnouncement < Announcement
	DEFAULT_ACCESSIBLE_ATTRIBUTES = [
		*Announcement::DEFAULT_ACCESSIBLE_ATTRIBUTES,
		:search_result_position,
		:search_result_link_text
	]

	auto_strip_attributes :search_result_link_text

	MAX_LENGTHS[:search_result_link_text] = 50

	validates :search_result_link_text, length: { maximum: MAX_LENGTHS[:search_result_link_text] }

	scope :search_result, -> { where("active is true and search_result_link_text is not null") }

	def self.search_results_to_display
		search_result.order("updated_at DESC").first(2)
	end

	def self.all_search_results
		where("search_result_link_text is not null").order("updated_at DESC")
	end
end
