class ShowStripeConnectAndAllowChargeAuthorizationsDefaultTrueInProfiles < ActiveRecord::Migration
	class Profile < ActiveRecord::Base
	end
	
	def up
		change_column_default :profiles, :show_stripe_connect, true
		change_column_default :profiles, :allow_charge_authorizations, true
		# Set to true for all existing profiles.
		execute <<-SQL
			UPDATE profiles SET show_stripe_connect = 't', allow_charge_authorizations = 't';
		SQL
	end

	def down
		change_column_default :profiles, :show_stripe_connect, false
		change_column_default :profiles, :allow_charge_authorizations, false
		# Revert to false for all existing profiles except those already connected to Stripe.
		execute <<-SQL
			UPDATE profiles SET show_stripe_connect = 'f', allow_charge_authorizations = 'f';
		SQL
		# Find payable providers, then allow Stripe Connect and charge authorizations for them.
		Profile.reset_column_information
		StripeInfo.where('user_id IS NOT NULL').map(&:user).map(&:profile).compact.each do |profile|
			profile.update_column :show_stripe_connect, true
			profile.update_column :allow_charge_authorizations, true
		end
	end
end
