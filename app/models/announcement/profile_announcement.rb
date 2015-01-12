class ProfileAnnouncement < Announcement
	attr_accessible :body, :headline, :button_or_link_url

	# Strip leading and trailing whitespace from input intended for these attributes.
	auto_strip_attributes :body, :headline, :button_or_link_url

	MAX_LENGTHS[:headline] = 50
	MAX_LENGTHS[:body] =  150

	[:headline, :body].each do |attribute|
		validates attribute, presence: true, length: {maximum: MAX_LENGTHS[attribute]}
	end

	validates :button_or_link_url, presence: true
	validates_format_of :button_or_link_url, with: /^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/i
end
