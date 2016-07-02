class StripeChargesController < ApplicationController
	
	respond_to :html
	
	before_action :authenticate_user!
	
	# Side effect: loads @stripe_charges or @stripe_charge as appropriate.
	# e.g., for index action, @stripe_charges is set to StripeCharge.accessible_by(current_ability)
	# For actions specified by the :new option, a new stripe_charge will be built rather than fetching one.
	load_and_authorize_resource

	# GET /stripe_charges/:id
	def show
		respond_with @stripe_charge
	end
	
	# # GET /stripe_charges/:id/new_refund
	# def new_refund
	# 	respond_with @stripe_charge
	# end
	
	# PUT /stripe_charges/:id/create_refund
	def create_refund
		respond_with @stripe_charge do |format|
			if @stripe_charge.create_refund(stripe_charge_params)
				set_flash_message :notice, :created_refund
			else
				format.html { render :show }
			end
		end
	end
	
	private
	
	# Use this method to whitelist the permissible parameters. Example:
	# params.require(:person).permit(:name, :age)
	# Also, you can specialize this method with per-user checking of permissible attributes.
	def stripe_charge_params
		params.require(:stripe_charge).permit(*StripeCharge::DEFAULT_ACCESSIBLE_ATTRIBUTES)
	end
end
