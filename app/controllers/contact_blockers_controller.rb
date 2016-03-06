class ContactBlockersController < ApplicationController
	respond_to :html
	
	before_filter :authenticate_user!, except: [:new_from_email_delivery, :create_from_email_delivery, :email_delivery_not_found, :contact_blocker_confirmation]
	
	# Side effect: loads @contact_blockers or @contact_blocker as appropriate.
	# e.g., for index action, @contact_blockers is set to ContactBlocker.accessible_by(current_ability)
	# For actions specified by the :new option, a new contact_blocker will be built rather than fetching one.
	load_and_authorize_resource
	skip_load_resource only: [:new_from_email_delivery, :create_from_email_delivery]
	skip_load_and_authorize_resource only: [:email_delivery_not_found, :contact_blocker_confirmation]
	
	before_filter :load_from_email_delivery, only: [:new_from_email_delivery, :create_from_email_delivery]
	
	def new_from_email_delivery
		if @contact_blocker
			respond_with @contact_blocker
		else
			redirect_to email_delivery_not_found_url
		end
	end
	
	def create_from_email_delivery
		if @contact_blocker
			if @contact_blocker.update_attributes_from_email_delivery contact_blocker_params
				redirect_to contact_blocker_confirmation_url
			else
				render action: :new_from_email_delivery
			end
		else
			redirect_to email_delivery_not_found_url
		end
	end
	
	def index
		@contact_blockers = @contact_blockers.order_by_descending_id.page(params[:page]).per(params[:per_page])
		respond_with @contact_blockers, layout: 'plain'
	end

	def show
		render layout: 'plain'
	end

	def new
		render layout: 'plain'
	end

	def edit
		render layout: 'plain'
	end

	def create
		respond_with(@contact_blocker) do |format|
			if @contact_blocker.save
				set_flash_message :notice, :created, email: @contact_blocker.email
			else
				set_flash_message :alert, :create_error
				format.html { render 'new', layout: 'plain' }
			end
		end
	end

	def update
		respond_with(@contact_blocker) do |format|
			if @contact_blocker.update_attributes contact_blocker_params
				set_flash_message :notice, :updated, email: @contact_blocker.email
			else
				set_flash_message :alert, :update_error
				format.html { render 'edit', layout: 'plain' }
			end
		end
	end

	def destroy
		@contact_blocker.destroy
		if @contact_blocker.destroyed?
			set_flash_message :notice, :destroyed, email: @contact_blocker.email
		else
			set_flash_message :alert, :destroy_error, email: @contact_blocker.email
		end
		respond_with @contact_blocker
	end
	
	private
	
	def load_from_email_delivery
		if (token = params[:email_delivery_token]).present? and (email_delivery = EmailDelivery.find_by_token token)
			@contact_blocker = email_delivery.contact_blockers.build email: email_delivery.recipient
		end
	end
	
	# Use this method to whitelist the permissible parameters. Example:
	# params.require(:person).permit(:name, :age)
	# Also, you can specialize this method with per-user checking of permissible attributes.
	def contact_blocker_params
		params.require(:contact_blocker).permit(*ContactBlocker::DEFAULT_ACCESSIBLE_ATTRIBUTES)
	end
end
