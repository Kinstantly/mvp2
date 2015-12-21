FactoryGirl.define do
	factory :story_teaser do
		active true
		display_order 1
		url "http://example.org/FactoryUrl"
		image_file "FactoryImageFile"
		title "FactoryTitle"
		css_class "FactoryCssClass"
	end
end
