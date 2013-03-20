require 'spec_helper'

describe Rating do
	it "has a score attribute" do
		rating = Rating.new
		rating.score = 2.5
		rating.should have(:no).errors_on(:score)
	end
end
