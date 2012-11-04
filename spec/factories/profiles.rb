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
		address1 "MyString"
		address2 "MyString"
		city "MyString"
		region "MyString"
		country "MyString"
		insurance_accepted false
	end
end
