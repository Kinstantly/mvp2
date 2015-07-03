require 'spec_helper'

describe Review, :type => :model do
	let(:review) { Review.new }
	let(:review_by_parent) { FactoryGirl.create :review_by_parent }
	
	it "has a body attribute" do
		review.body = 'Luciano Pavarotti can sing!'
		expect(review).to have(:no).errors_on(:body)
	end
	
	it "has a title attribute" do
		review.title = 'E serbata a questo acciaro'
		expect(review).to have(:no).errors_on(:title)
	end
	
	it "has a good_to_know attribute" do
		review.good_to_know = 'Giulietta'
		expect(review).to have(:no).errors_on(:good_to_know)
	end
	
	it "has a reviewer email virtual attribute" do
		review.reviewer_email = 'jsutherland@la.stupenda.au'
		expect(review).to have(:no).errors_on(:reviewer_email)
	end
	
	it "has a reviewer username virtual attribute" do
		review.reviewer_username = 'jsutherland'
		expect(review).to have(:no).errors_on(:reviewer_username)
	end
	
	it "limits the number of input characters for attributes stored as string or text records" do
		[:title, :body, :good_to_know].each do |attr|
			s = 'a' * Review::MAX_LENGTHS[attr]
			review.send "#{attr}=", s
			expect(review).to have(:no).errors_on(attr)
			review.send "#{attr}=", (s + 'a')
			expect(review).to have(1).error_on(attr)
		end
	end
	
	it "should create a user record for the reviewer" do
		review.body = body = 'Luciano Pavarotti can sing!'
		review.reviewer_email = email = 'jsutherland@la.stupenda.au'
		review.reviewer_username = 'jsutherland'
		review.save_with_reviewer
		user = User.find_by_email email
		expect(user).not_to be_nil
		expect(user.reviews_given.size).to eq 1
		expect(user.reviews_given.first.body).to eq body
	end
	
	it "can change the reviewer" do
		new_reviewer = FactoryGirl.create :parent, email: 'jsutherland@la.stupenda.au', username: 'jsutherland'
		review_by_parent.update_attributes_with_reviewer reviewer_email: new_reviewer.email
		expect(Review.find(review_by_parent.id).reviewer).to eq new_reviewer
	end
	
	context "rating" do
		before(:each) do
			review_by_parent.profile.rate nil, review_by_parent.reviewer
		end
		
		it "has access to the reviewer's provider rating" do
			score = 4
			review_by_parent.profile.rate score, review_by_parent.reviewer
			expect(review_by_parent.rating.score).to eq score
		end
	
		it "can be used to set the reviewer's provider rating" do
			score = 3
			review_by_parent.rate score
			expect(review_by_parent.profile.rating_by(review_by_parent.reviewer).score).to eq score
		end
		
		it "should validate score" do
			expect(review_by_parent.rate(100)).to be_falsey
			expect(review_by_parent.errors[:rating]).not_to be_nil
		end
	end
end
