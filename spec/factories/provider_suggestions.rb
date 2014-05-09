# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :provider_suggestion do
		suggester_name "FactorySuggesterName"
		suggester_email "FactorySuggesterEmail@example.org"
		provider_name "FactoryProviderName"
		provider_url "FactoryProviderUrl"
		description "FactoryDescriptionWith20Characters"
		
		factory :provider_suggestion_by_parent do
			association :suggester, factory: :parent
			suggester_name nil
			suggester_email nil
		end
	end
end
