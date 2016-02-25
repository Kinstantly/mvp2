class CategoriesController < ApplicationController
	layout 'plain'
	
	before_filter :authenticate_user!
	
	# @category and @categories initialized by load_and_authorize_resource with cancan ability conditions.
	load_and_authorize_resource
	skip_load_resource only: :autocomplete_subcategory_name
	
	# This is dependent on @category (the resource) being loaded.
	before_filter :load_category_subcategory, only: [:update_subcategory, :remove_subcategory]
	
	# Autocomplete subcategory names.
	autocomplete :subcategory, :name, full: true
	
	def index
		@categories = @categories.home_page_order.page(params[:page]).per(20)
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
		if @category.update_attributes(category_params)
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
	
	def add_subcategory
		if (name = params[:name]).present? and (subcategory = name.to_subcategory) and (! @category.subcategories.include?(subcategory))
			# Add subcategory.
			@category.subcategories << subcategory
			set_flash_message :notice, :add_subcategory_success, name: subcategory.name
			# Set display order.
			category_subcategory = @category.category_subcategory(subcategory)
			category_subcategory.subcategory_display_order = params[:subcategory_display_order]
			unless category_subcategory.save
				set_flash_message :alert, :subcategory_display_order_error, name: subcategory.name
			end
		else
			set_flash_message :alert, :add_subcategory_error, name: name
		end
		redirect_to edit_category_path(@category)
	end
	
	def update_subcategory
		if @category.category_subcategory(@subcategory).try(:update_attributes, subcategory_display_order: params[:subcategory_display_order])
			set_flash_message :notice, :update_subcategory_success, name: @subcategory.name
		else
			set_flash_message :alert, :update_subcategory_error
		end
		redirect_to edit_category_path(@category)
	end
	
	def remove_subcategory
		if @subcategory
			@category.subcategories.delete @subcategory
			set_flash_message :notice, :remove_subcategory_success, name: @subcategory.name
		else
			set_flash_message :alert, :remove_subcategory_error
		end
		redirect_to edit_category_path(@category)
	end
	
	private
	
	def load_category_subcategory
		if (subcategory_id = params[:subcategory_id]).present? and (subcategory = Subcategory.find(subcategory_id)) and (@category.subcategories.include?(subcategory))
			@subcategory = subcategory
		end
	end
	
	# Use this method to whitelist the permissible parameters. Example:
	# params.require(:person).permit(:name, :age)
	# Also, you can specialize this method with per-user checking of permissible attributes.
	def category_params
		params.require(:category).permit(*Category::DEFAULT_ACCESSIBLE_ATTRIBUTES)
	end
end
