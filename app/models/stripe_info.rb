class StripeInfo < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :stripe_user_id, :access_token, :publishable_key
end
