require 'spec_helper'

RSpec.describe StoryTeaser, :type => :model do
	let(:story_teaser) { FactoryGirl.build :story_teaser }
	
	it "must have values for the required attributes" do
		[:display_order, :image_file, :title, :url].each do |attribute|
			story_teaser.send "#{attribute}=", nil
			expect(story_teaser.error_on(attribute)).to be_present
		end
	end
	
	it "limits the number of input characters for attributes stored as string or text records" do
		[:css_class, :image_file, :title, :url].each do |attribute|
			s = 'a' * StoryTeaser::MAX_LENGTHS[attribute]
			story_teaser.send "#{attribute}=", s
			expect(story_teaser.errors_on(attribute)).to be_empty
			story_teaser.send "#{attribute}=", (s + 'a')
			expect(story_teaser.error_on(attribute)).to be_present
		end
	end
	
	it 'can be activated' do
		story_teaser.active = false
		story_teaser.save
		expect {
			story_teaser.activate
		}.to change {
			story_teaser.reload.active
		}.from(false).to(true)
	end
	
	it 'can be deactivated' do
		story_teaser.active = true
		story_teaser.save
		expect {
			story_teaser.deactivate
		}.to change {
			story_teaser.reload.active
		}.from(true).to(false)
	end
	
	it 'can be ordered by descending ID' do
		id1 = (FactoryGirl.create :story_teaser).id
		id2 = (FactoryGirl.create :story_teaser).id
		expect(StoryTeaser.order_by_descending_id.first.id).to eq (id1 > id2 ? id1 : id2)
		expect(StoryTeaser.order_by_descending_id.last.id).to eq (id1 < id2 ? id1 : id2)
	end
	
	it 'can be ordered for display' do
		story_teaser_to_display_last = FactoryGirl.create :story_teaser, display_order: 99
		story_teaser_to_display_first = FactoryGirl.create :story_teaser, display_order: 1
		expect(StoryTeaser.order_by_display_order.first).to eq story_teaser_to_display_first
		expect(StoryTeaser.order_by_display_order.last).to eq story_teaser_to_display_last
	end
	
	it 'can be sorted by active status followed by display order' do
		story_teaser_1 = FactoryGirl.create :story_teaser, active: false, display_order: 1
		story_teaser_2 = FactoryGirl.create :story_teaser, active: false, display_order: 2
		# Major sort by active status.
		expect {
			story_teaser_2.active = true
			story_teaser_2.save
		}.to change {
			StoryTeaser.order_by_active_display_order.first
		}.from(story_teaser_1).to(story_teaser_2)
		# Minor sort by display order.
		expect {
			story_teaser_1.active = true
			story_teaser_1.save
		}.to change {
			StoryTeaser.order_by_active_display_order.first
		}.from(story_teaser_2).to(story_teaser_1)
	end
	
	it 'can be selected by active status' do
		story_teaser.active = false
		story_teaser.save
		expect {
			story_teaser.active = true
			story_teaser.save
		}.to change {
			StoryTeaser.active_only.include?(story_teaser)
		}.from(false).to(true)
	end
	
	it 'can create a tracked URL' do
		post = 'peaceable-kingdom-donna-jaffe'
		url = "https://blog.kinstantly.com/#{post}/"
		source = 'directory_home'
		medium = 'banner'
		position = 1
		tracked_url = "#{url}?utm_source=#{source}&utm_medium=#{medium}&utm_content=position_#{position}&utm_campaign=blog_#{post}"
		story_teaser.url = url
		expect(story_teaser.tracked_url(source, medium, position)).to eq tracked_url
	end
end
