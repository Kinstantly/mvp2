# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :profile do
		first_name "FactoryFirstName"
		last_name "FactoryLastName"
		middle_name "FactoryMiddleName"
		company_name "FactoryCompanyName"
		url "FactoryURL"
		mobile_phone "FactoryMobilePhone"
		office_phone "FactoryOfficePhone"
		insurance_accepted 'FactoryInsuranceAccepted'
		
		after(:build) { |profile|
			profile.categories = [FactoryGirl.create(:category)] if profile.categories.blank?
			profile.specialties = [FactoryGirl.create(:specialty)] if profile.specialties.blank?
		}
	end
end
