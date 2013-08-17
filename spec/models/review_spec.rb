require 'spec_helper'

describe Review do
	let(:review) { Review.new }
	
	it "has a body attribute" do
		review.body = 'Luciano Pavarotti can sing!'
		review.should have(:no).errors_on(:body)
	end
	
	it "has a reviewer email virtual attribute" do
		review.reviewer_email = 'jsutherland@la.stupenda.au'
		review.should have(:no).errors_on(:reviewer_email)
	end
	
	it "has a reviewer username virtual attribute" do
		review.reviewer_username = 'jsutherland'
		review.should have(:no).errors_on(:reviewer_username)
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
	
	it "should create a user record for the reviewer" do
		review.body = body = 'Luciano Pavarotti can sing!'
		review.reviewer_email = email = 'jsutherland@la.stupenda.au'
		review.reviewer_username = 'jsutherland'
		review.save
		(user = User.find_by_email email).should_not be_nil
		user.should have(1).review_given
		user.reviews_given.first.body.should == body
	end
end
