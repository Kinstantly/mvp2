FactoryGirl.define do
	factory :subscription_stage do
		title "FactoryTitle"
		source_campaign_id "FactorySourceCampaignId"
		list_id "FactoryListId"
		trigger_delay_days 1
	end

end
