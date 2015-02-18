# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :announcement do
		profile
		icon 0
		headline "FactoryHeadline"
		body "Factoryody"
		button_text "FactoryButtonText"
		button_url "FactoryButtonURL"
		start_at Time.zone.now
	end

	factory :profile_announcement do
		profile
		icon 0
		headline "FactoryHeadline"
		body "Factoryody"
		button_text "FactoryButtonText"
		button_url "FactoryButtonURL"
		start_at Time.zone.now
		search_result_position 0
	end
end
