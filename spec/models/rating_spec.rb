require 'spec_helper'

describe Rating, :type => :model do
	let(:rating) { Rating.new }
	
	it "has a score attribute" do
		rating.score = 2
		expect(rating.errors_on(:score).size).to eq 0
	end
	
	it "requires a score" do
		rating.score = nil
		expect(rating.error_on(:score).size).to be >= 1
	end
	
	it "must have a numeric score" do
		rating.score = 'five'
		expect(rating.error_on(:score).size).to eq 1
	end
	
	it "must have an integral score" do
		rating.score = 2.5
		expect(rating.error_on(:score).size).to eq 1
	end
	
	it "must have a score from 1 to 5" do
		rating.score = 0
		expect(rating.error_on(:score).size).to eq 1
		rating.score = 1
		expect(rating.errors_on(:score).size).to eq 0
		rating.score = 5
		expect(rating.errors_on(:score).size).to eq 0
		rating.score = 6
		expect(rating.error_on(:score).size).to eq 1
	end
end
