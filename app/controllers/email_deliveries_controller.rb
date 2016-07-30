class EmailDeliveriesController < ApplicationController
	layout 'plain'
	
	before_action :authenticate_user!
	
	# @email_delivery and @email_deliveries initialized by load_and_authorize_resource with cancan ability conditions.
	load_and_authorize_resource
	skip_load_resource only: [:new_list, :create_list]

	def index
		@order_by_options = { sender: 'sender', recipient: 'recipient', email_type: 'email type', recent: 'recent' }
		@email_deliveries = case params[:order_by]
		when 'sender'
			@email_deliveries.order(:sender)
		when 'recipient'
			@email_deliveries.order(:recipient)
		when 'email_type'
			@email_deliveries.order(:email_type)
		when 'recent'
			@email_deliveries.order('id DESC')
		else
			@email_deliveries.order('id DESC')
		end.page(params[:page]).per(params[:per_page])
	end

	def new
		@email_delivery.sender = current_user.try :email
		@email_delivery.email_type = 'provider_sell'
	end
	
	def create
		if @email_delivery.save
			set_flash_message :notice, :created, recipient: @email_delivery.recipient
			redirect_to email_delivery_path(@email_delivery)
		else
			set_flash_message :alert, :create_error
			render action: :new
		end
	end

	def new_list
	end
	
	def create_list
		
	end

	# def edit
	# end
	
	def update
		if @email_delivery.update_attributes(email_delivery_params)
			set_flash_message :notice, :updated, recipient: @email_delivery.recipient
			redirect_to email_delivery_path(@email_delivery)
		else
			set_flash_message :alert, :update_error
			render action: :edit
		end
	end
	
	def destroy
		if @email_delivery.destroy
			set_flash_message :notice, :destroyed, recipient: @email_delivery.recipient
			redirect_to email_deliveries_url
		else
			set_flash_message :alert, :destroy_error
			render action: :edit
		end
	end
	
	private
	
	# Use this method to whitelist the permissible parameters. Example:
	# params.require(:person).permit(:name, :age)
	# Also, you can specialize this method with per-user checking of permissible attributes.
	def email_delivery_params
		params.require(:email_delivery).permit(*EmailDelivery::DEFAULT_ACCESSIBLE_ATTRIBUTES)
	end
end
