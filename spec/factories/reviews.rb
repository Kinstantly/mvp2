# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :review do
		body 'FactoryBody FactoryBody FactoryBody FactoryBody FactoryBody'
		reviewer_email 'FactoryReviewerEmail@example.com'
		reviewer_username 'FactoryReviewerUsername'
		rating
		# after(:build) do |review|
		# 	review.rating = FactoryGirl.create(:rating, review: review)
		# end
	end
end
