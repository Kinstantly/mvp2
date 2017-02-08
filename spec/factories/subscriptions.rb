FactoryGirl.define do
	factory :subscription do
		subscribed false
		status "FactoryStatus"
		list_id "FactoryListId"
		subscriber_hash "FactorySubscriberHash"
		unique_email_id "FactoryUniqueEmailId"
		email "FactoryEmail@kinstantly.com"
		fname "FactoryFname"
		lname "FactoryLname"
		birth1 "2017-02-06"
		birth2 "2015-02-06"
		birth3 "2013-02-06"
		birth4 "2011-02-06"
		zip_code "FactoryZipCode"
		postal_code "94107"
		country "US"
		subsource "FactorySubsource"
	end

end
