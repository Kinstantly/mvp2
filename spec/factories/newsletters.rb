# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :newsletter do
		cid 'FactoryCID'
		list_id "FactoryListID"
		title "FactoryTitle"
		subject "FactorySubject"
		archive_url "FactoryURL"
		content "<html></html>"
		send_time Time.zone.now
	end
end
