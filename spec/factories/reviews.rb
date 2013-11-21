# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :review do
		title 'FactoryTitle'
		body 'FactoryBody FactoryBody FactoryBody FactoryBody FactoryBody'
		good_to_know 'FactoryGoodToKnow'
		
		# rating
		
		factory :review_by_parent do
			association :reviewer, factory: :parent
			association :profile, factory: :published_profile
		end
	end
end
