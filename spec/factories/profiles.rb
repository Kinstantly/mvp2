# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :profile do
		first_name "FactoryFirstName"
		last_name "FactoryLastName"
		middle_name "FactoryMiddleName"
		company_name "FactoryCompanyName"
		url "FactoryURL"
		insurance_accepted 'FactoryInsuranceAccepted'
		
		after(:build) { |profile|
			profile.categories = [FactoryGirl.create(:category)] if profile.categories.blank?
			profile.services = [FactoryGirl.create(:service)] if profile.services.blank?
			profile.specialties = [FactoryGirl.create(:specialty)] if profile.specialties.blank?
		}
		
		factory :published_profile do
			is_published true
		end
		
		factory :unpublished_profile do
			is_published false
		end
	end
end
