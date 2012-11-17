# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :profile do
		first_name "MyString"
		last_name "MyString"
		middle_name "MyString"
		company_name "MyString"
		url "MyString"
		mobile_phone "MyString"
		office_phone "MyString"
		insurance_accepted 'MyString'
		categories ['MyString']
		specialties ['MyString']
	end
end
