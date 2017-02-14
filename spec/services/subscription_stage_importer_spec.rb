require 'spec_helper'

describe SubscriptionStageImporter, mailchimp: true do
	let(:list) { :parent_newsletters }
	let(:list_id) { mailchimp_list_ids[list] }
	let(:folder) { :parent_newsletters_source_campaigns }
	let(:folder_id) { mailchimp_folder_ids[folder] }
	
	let(:stage_importer_params) { {
		list: list,
		folder: folder
	} }
	let(:stage_importer) { SubscriptionStageImporter.new(stage_importer_params) }

	let(:stage_importer_error) {
		SubscriptionStageImporter.new(stage_importer_params.merge folder: nil)
	}
	
	context 'with valid parameters' do
		it 'should return success' do
			expect(stage_importer.call).to be_truthy
		end
	
		it 'should have a success status' do
			stage_importer.call
			expect(stage_importer).to be_successful
		end
		
		it 'should create subscription stage records' do
			title_list = [
				'Your Child is 3 YEARS, 1 month',
				'Your Child is 3 YEARS, 2 months',
				'Your Child is 3 YEARS, 3 months'
			]
			
			title_list.each do |title|
				Gibbon::Request.campaigns.create body: {
					type: 'regular',
					settings: {
						folder_id: folder_id,
						title: title,
						subject_line: title,
						from_name: 'Kinstantly',
						reply_to: 'kinstantly@kinstantly.com'
					}
				}
			end
			
			expect {
				stage_importer.call
			}.to change(SubscriptionStage, :count).by(title_list.size)
		end
		
		it "should import the source-campaign ID" do
			title = 'Your Child is 3 YEARS, 1 month'
			
			campaign = Gibbon::Request.campaigns.create body: {
				type: 'regular',
				settings: {
					folder_id: folder_id,
					title: title,
					subject_line: title,
					from_name: 'Kinstantly',
					reply_to: 'kinstantly@kinstantly.com'
				}
			}
			
			stage_importer.call
			subscription_stage = SubscriptionStage.last
			expect(subscription_stage.source_campaign_id).to eq campaign['id']
		end
		
		it "should import the source-campaign title" do
			title = 'Your Child is 3 YEARS, 1 month'
			
			Gibbon::Request.campaigns.create body: {
				type: 'regular',
				settings: {
					folder_id: folder_id,
					title: title,
					subject_line: title,
					from_name: 'Kinstantly',
					reply_to: 'kinstantly@kinstantly.com'
				}
			}
			
			stage_importer.call
			subscription_stage = SubscriptionStage.last
			expect(subscription_stage.title).to eq title
		end
	end
	
	context 'with invalid parameters' do
		it 'should not return success' do
			expect(stage_importer_error.call).to be_falsey
		end
	
		it 'should not have a success status' do
			stage_importer_error.call
			expect(stage_importer_error).not_to be_successful
		end
	end
end
