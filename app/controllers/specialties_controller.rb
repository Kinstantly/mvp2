class SpecialtiesController < ApplicationController
	
	before_filter :authenticate_user!
	
	# @specialty and @specialties initialized by load_and_authorize_resource with cancan ability conditions.
	load_and_authorize_resource
	skip_load_resource only: :find_by_name
	
	def index
		@specialties = @specialties.order_by_name.page(params[:page]).per(20)
	end
	
	def new
		@specialty.is_predefined = true
	end
	
	def create
		if @specialty.save
			set_flash_message :notice, :created, name: @specialty.name
			redirect_to specialties_url
		else
			set_flash_message :alert, :create_error
			render action: :new
		end
	end
	
	def update
		if @specialty.update_attributes(params[:specialty])
			set_flash_message :notice, :updated, name: @specialty.name
			redirect_to specialties_url
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
end
