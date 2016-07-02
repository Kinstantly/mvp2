class SubcategoriesController < ApplicationController
	layout 'plain'
	
	before_action :authenticate_user!
	
	# @subcategory and @subcategories initialized by load_and_authorize_resource with cancan ability conditions.
	load_and_authorize_resource
	skip_load_resource only: :autocomplete_service_name
	
	# This is dependent on @subcategory (the resource) being loaded.
	before_action :load_subcategory_service, only: [:update_service, :remove_service]
	
	# Autocomplete service names.
	autocomplete :service, :name, full: true
	
	def index
		@subcategories = @subcategories.order_by_name.page(params[:page]).per(params[:per_page])
	end
	
	# def new
	# end
	
	def create
		if @subcategory.save
			set_flash_message :notice, :created, name: @subcategory.name
			redirect_to edit_subcategory_path(@subcategory)
		else
			set_flash_message :alert, :create_error
			render action: :new
		end
	end
	
	def update
		if @subcategory.update_attributes(subcategory_params)
			set_flash_message :notice, :updated, name: @subcategory.name
			redirect_to edit_subcategory_path(@subcategory)
		else
			set_flash_message :alert, :update_error
			render action: :edit
		end
	end
	
	def destroy
		@subcategory.trash = true
		if @subcategory.save
			set_flash_message :notice, :destroyed, name: @subcategory.name
			redirect_to subcategories_url
		else
			set_flash_message :alert, :destroy_error
			render action: :edit
		end
	end
	
	def add_service
		if (name = params[:name]).present? and (service = name.to_service) and (! @subcategory.services.include?(service))
			# Add service.
			@subcategory.services << service
			set_flash_message :notice, :add_service_success, name: service.name
			# Set display order.
			service_subcategory = @subcategory.service_subcategory(service)
			service_subcategory.service_display_order = params[:service_display_order]
			unless service_subcategory.save
				set_flash_message :alert, :service_display_order_error, name: service.name
			end
		else
			set_flash_message :alert, :add_service_error, name: name
		end
		redirect_to edit_subcategory_path(@subcategory)
	end
	
	def update_service
		if @subcategory.service_subcategory(@service).try(:update_attributes, service_display_order: params[:service_display_order])
			set_flash_message :notice, :update_service_success, name: @service.name
		else
			set_flash_message :alert, :update_service_error
		end
		redirect_to edit_subcategory_path(@subcategory)
	end
	
	def remove_service
		if @service
			@subcategory.services.delete @service
			set_flash_message :notice, :remove_service_success, name: @service.name
		else
			set_flash_message :alert, :remove_service_error
		end
		redirect_to edit_subcategory_path(@subcategory)
	end
	
	def find_by_name
		name = params[:name]
		if name.present? && (subcategory = Subcategory.find_by_name name)
			redirect_to edit_subcategory_path(subcategory)
		else
			set_flash_message :alert, :not_found_by_name, name: name
			redirect_to subcategories_url
		end
	end
	
	private
	
	def load_subcategory_service
		if (service_id = params[:service_id]).present? and (service = Service.find(service_id)) and (@subcategory.services.include?(service))
			@service = service
		end
	end
	
	# Use this method to whitelist the permissible parameters. Example:
	# params.require(:person).permit(:name, :age)
	# Also, you can specialize this method with per-user checking of permissible attributes.
	def subcategory_params
		params.require(:subcategory).permit(*Subcategory::DEFAULT_ACCESSIBLE_ATTRIBUTES)
	end
end
