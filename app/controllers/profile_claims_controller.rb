class ProfileClaimsController < ApplicationController
	respond_to :html, :js
	
	before_filter :authenticate_user_on_public_site, except: [:new, :create]
	before_filter :authenticate_user_on_private_site
	
	# Side effect: loads @profile_claims or @profile_claim as appropriate.
	# e.g., for index action, @profile_claims is set to ProfileClaim.accessible_by(current_ability)
	# For actions specified by the :new option, a new profile_claim will be built rather than fetching one.
	load_and_authorize_resource

	before_filter :load_profile, only: [:new, :create]
	
	# GET /profile_claims/new
	def new
		@profile_claim.claimant_email = current_user.email if user_signed_in?
		respond_with @profile_claim, layout: false
	end
	
	# POST /profile_claims
	def create
		@profile_claim.claimant = current_user if user_signed_in?
		@profile_claim.save
		respond_with @profile_claim, layout: false
	end
	
	# GET /profile_claims
	def index
		@profile_claims = @profile_claims.order_by_descending_id.page(params[:page]).per(params[:per_page])
		render layout: 'plain'
	end
	
	# GET /profile_claims/1
	def show
		render layout: 'plain'
	end
	
	# GET /profile_claims/1/edit
	def edit
		render layout: 'plain'
	end
	
	# PUT /profile_claims/1
	def update
		role = current_user.try(:admin?) ? :admin : :default
		if @profile_claim.update_attributes params[:profile_claim], as: role
			set_flash_message :notice, :updated
			respond_with @profile_claim
		else
			set_flash_message :alert, :update_error
			render action: :edit, layout: 'plain'
		end
	end

	# DELETE /profile_claims/1
	def destroy
		@profile_claim.destroy
		provider_name = @profile_claim.profile.present? ? @profile_claim.profile.display_name  : 'unknown'
		if @profile_claim.destroyed?
			set_flash_message :notice, :destroyed, name: provider_name
		else
			set_flash_message :alert, :destroy_error, name: provider_name
		end
		respond_with @profile_claim
	end

	private
	
	def load_profile
		if (id = params[:profile_id]).present?
			@profile = Profile.accessible_by(current_ability, :show).find(id)
			@profile_claim.profile = @profile
		end
	end

end
