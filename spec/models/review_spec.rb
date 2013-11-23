require 'spec_helper'

describe Review do
	let(:review) { Review.new }
	let(:review_by_parent) { FactoryGirl.create :review_by_parent }
	
	it "has a body attribute" do
		review.body = 'Luciano Pavarotti can sing!'
		review.should have(:no).errors_on(:body)
	end
	
	it "has a title attribute" do
		review.title = 'E serbata a questo acciaro'
		review.should have(:no).errors_on(:title)
	end
	
	it "has a good_to_know attribute" do
		review.good_to_know = 'Giulietta'
		review.should have(:no).errors_on(:good_to_know)
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
		[:title, :body, :good_to_know].each do |attr|
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
		review.save_with_reviewer
		(user = User.find_by_email email).should_not be_nil
		user.should have(1).review_given
		user.reviews_given.first.body.should == body
	end
	
	it "can change the reviewer" do
		new_reviewer = FactoryGirl.create :parent, email: 'jsutherland@la.stupenda.au', username: 'jsutherland'
		review_by_parent.update_attributes_with_reviewer reviewer_email: new_reviewer.email
		Review.find(review_by_parent.id).reviewer.should == new_reviewer
	end
	
	context "rating" do
		before(:each) do
			review_by_parent.profile.rate nil, review_by_parent.reviewer
		end
		
		it "has access to the reviewer's provider rating" do
			score = 4
			review_by_parent.profile.rate score, review_by_parent.reviewer
			review_by_parent.rating.score.should == score
		end
	
		it "can be used to set the reviewer's provider rating" do
			score = 3
			review_by_parent.rate score
			review_by_parent.profile.rating_by(review_by_parent.reviewer).score.should == score
		end
		
		it "should validate score" do
			review_by_parent.rate(100).should be_false
			review_by_parent.errors[:rating].should_not be_nil
		end
	end
end
