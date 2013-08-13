require 'spec_helper'

describe Review do
	it "has a body attribute" do
		review = Review.new
		review.body = 'Luciano Pavarotti can sing!'
		review.should have(:no).errors_on(:body)
	end
end
