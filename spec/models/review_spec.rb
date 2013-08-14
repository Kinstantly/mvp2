require 'spec_helper'

describe Review do
	let(:review) { Review.new }
	
	it "has a body attribute" do
		review.body = 'Luciano Pavarotti can sing!'
		review.should have(:no).errors_on(:body)
	end
	
	it "limits the number of input characters for attributes stored as string or text records" do
		[:body].each do |attr|
			s = 'a' * Review::MAX_LENGTHS[attr]
			review.send "#{attr}=", s
			review.should have(:no).errors_on(attr)
			review.send "#{attr}=", (s + 'a')
			review.should have(1).error_on(attr)
		end
	end
end
