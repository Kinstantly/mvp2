class SpecialtiesController < ApplicationController
	layout 'plain'
	
	before_filter :authenticate_user!
	
	# @specialty and @specialties initialized by load_and_authorize_resource with cancan ability conditions.
	load_and_authorize_resource
	skip_load_resource only: :find_by_name
	skip_load_and_authorize_resource only: :autocomplete_search_term_name
	
	# Autocomplete search term names.
	autocomplete :search_term, :name, full: true
	
	def index
		@specialties = @specialties.order_by_name.page(params[:page]).per(params[:per_page])
	end
	
	def new
		@specialty.is_predefined = true
	end
	
	def create
		if @specialty.save
			set_flash_message :notice, :created, name: @specialty.name
			redirect_to edit_specialty_path(@specialty)
		else
			set_flash_message :alert, :create_error
			render action: :new
		end
	end
	
	def update
		if @specialty.update_attributes(specialty_params)
			if (service_id = params[:service_id]).present?
				# We came from a mini-form on a service admin page.
				redirect_to edit_service_path(service_id, anchor: 'links')
			else
				set_flash_message :notice, :updated, name: @specialty.name
				redirect_to edit_specialty_path(@specialty)
			end
		else
			set_flash_message :alert, :update_error
			render action: :edit
		end
	end
	
	def destroy
		@specialty.trash = true
		if @specialty.save
			set_flash_message :notice, :destroyed, name: @specialty.name
			redirect_to specialties_url
		else
			set_flash_message :alert, :destroy_error
			render action: :edit
		end
	end
	
	def find_by_name
		name = params[:name]
		if name.present? && (specialty = Specialty.find_by_name name)
			redirect_to edit_specialty_path(specialty)
		else
			set_flash_message :alert, :not_found_by_name, name: name
			redirect_to specialties_url
		end
	end
	
	private
	
	# Use this method to whitelist the permissible parameters. Example:
	# params.require(:person).permit(:name, :age)
	# Also, you can specialize this method with per-user checking of permissible attributes.
	def specialty_params
		params.require(:specialty).permit(*Specialty::DEFAULT_ACCESSIBLE_ATTRIBUTES)
	end
end
