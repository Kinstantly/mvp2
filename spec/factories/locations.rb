# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :location do
    address1 "FactoryAddress1"
    address2 "FactoryAddress2"
    city "FactoryCity"
    region DEFAULT_REGION # Valid region to be safe.
    country DEFAULT_COUNTRY_CODE # Need a valid country code to ensure a successful look-up of subregion.
    postal_code "FactoryPostalCode"
    phone "1-505-666-7777"
  end
end
