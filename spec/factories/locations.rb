# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :location do
    address1 "FactoryAddress1"
    address2 "FactoryAddress2"
    city "FactoryCity"
    region "FactoryRegion"
    country "FactoryCountry"
    postal_code "FactoryPostalCode"
  end
end
