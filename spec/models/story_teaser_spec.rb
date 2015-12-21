require 'spec_helper'

RSpec.describe StoryTeaser, :type => :model do
	let(:story_teaser) { FactoryGirl.create :story_teaser }
	
	it "must have values for the required attributes" do
		[:display_order, :image_file, :title, :url].each do |attribute|
			story_teaser.send "#{attribute}=", nil
			expect(story_teaser.error_on(attribute).size).to eq 1
		end
	end
	
	it "limits the number of input characters for attributes stored as string or text records" do
		[:css_class, :image_file, :title, :url].each do |attribute|
			s = 'a' * StoryTeaser::MAX_LENGTHS[attribute]
			story_teaser.send "#{attribute}=", s
			expect(story_teaser.errors_on(attribute).size).to eq 0
			story_teaser.send "#{attribute}=", (s + 'a')
			expect(story_teaser.error_on(attribute).size).to eq 1
		end
	end
end
