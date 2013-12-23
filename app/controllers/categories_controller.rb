class CategoriesController < ApplicationController
	layout 'plain'
	
	before_filter :authenticate_user!
	
	# @category and @categories initialized by load_and_authorize_resource with cancan ability conditions.
	load_and_authorize_resource
	
	cache_sweeper :category_sweeper
	
	def index
		@categories = @categories.order_by_name.page(params[:page]).per(20)
	end
	
	def new
		@category.is_predefined = true
	end
	
	def create
		if @category.save
			set_flash_message :notice, :created, name: @category.name
			redirect_to edit_category_path(@category)
		else
			set_flash_message :alert, :create_error
			render action: :new
		end
	end
	
	def update
		if @category.update_attributes(params[:category])
			set_flash_message :notice, :updated, name: @category.name
			redirect_to edit_category_path(@category)
		else
			set_flash_message :alert, :update_error
			render action: :edit
		end
	end
	
	def destroy
		@category.trash = true
		if @category.save
			set_flash_message :notice, :destroyed, name: @category.name
			redirect_to categories_url
		else
			set_flash_message :alert, :destroy_error
			render action: :edit
		end
	end
	
end
