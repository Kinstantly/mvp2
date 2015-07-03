require 'spec_helper'

describe Rating, :type => :model do
	let(:rating) { Rating.new }
	
	it "has a score attribute" do
		rating.score = 2
		expect(rating).to have(:no).errors_on(:score)
	end
	
	it "requires a score" do
		rating.score = nil
		expect(rating).to have_at_least(1).error_on(:score)
	end
	
	it "must have a numeric score" do
		rating.score = 'five'
		expect(rating).to have(1).error_on(:score)
	end
	
	it "must have an integral score" do
		rating.score = 2.5
		expect(rating).to have(1).error_on(:score)
	end
	
	it "must have a score from 1 to 5" do
		rating.score = 0
		expect(rating).to have(1).error_on(:score)
		rating.score = 1
		expect(rating).to have(:no).errors_on(:score)
		rating.score = 5
		expect(rating).to have(:no).errors_on(:score)
		rating.score = 6
		expect(rating).to have(1).error_on(:score)
	end
end
