# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :review do
		body 'FactoryBody FactoryBody FactoryBody FactoryBody FactoryBody'
		reviewer_email 'FactoryReviewerEmail@example.com'
		reviewer_username 'FactoryReviewerUsername'
	end
end
