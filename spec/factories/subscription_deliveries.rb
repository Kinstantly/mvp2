FactoryGirl.define do
	factory :subscription_delivery do
		subscription nil
		subscription_stage nil
		email "FactoryEmail@kinstantly.com"
		source_campaign_id "FactorySourceCampaignId"
		campaign_id "FactoryCampaignId"
		schedule_time "2017-03-04 16:00:00"
		send_time "2017-03-04 16:04:42"
	end

end
