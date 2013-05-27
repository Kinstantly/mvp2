class ServicesController < ApplicationController
	
	before_filter :authenticate_user!
	
	# @service and @services initialized by load_and_authorize_resource with cancan ability conditions.
	load_and_authorize_resource
	
	def index
		@services = @services.order_by_name.page(params[:page]).per(20)
	end
	
	def new
		@service.is_predefined = true
	end
	
	def create
		if @service.save
			set_flash_message :notice, :created, name: @service.name
			redirect_to services_url
		else
			set_flash_message :alert, :create_error
			render action: :new
		end
	end
	
	def update
		if @service.update_attributes(params[:service])
			set_flash_message :notice, :updated, name: @service.name
			redirect_to services_url
		else
			set_flash_message :alert, :update_error
			render action: :edit
		end
	end
	
	def destroy
		@service.trash = true
		if @service.save
			set_flash_message :notice, :destroyed, name: @service.name
			redirect_to services_url
		else
			set_flash_message :alert, :destroy_error
			render action: :edit
		end
	end
	
	def find_by_name
		name = params[:name]
		if name.present? && (service = Service.find_by_name name)
			redirect_to edit_service_path(service)
		else
			set_flash_message :alert, :not_found_by_name, name: name
			redirect_to services_url
		end
	end
end
