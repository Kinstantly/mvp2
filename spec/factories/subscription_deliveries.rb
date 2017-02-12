FactoryGirl.define do
	factory :subscription_delivery do
		subscription nil
		subscription_stage nil
		email "FactoryEmail@kinstantly.com"
		source_campaign_id "FactorySourceCampaignId"
		campaign_id "FactoryCampaignId"
		send_time "2017-02-11 23:04:42"
	end

end
