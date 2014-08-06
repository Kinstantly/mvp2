# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :profile_claim do
    claimant_email "claimant@claim.com"
    claimant_phone "888-888-8888"
    profile
  end
end
