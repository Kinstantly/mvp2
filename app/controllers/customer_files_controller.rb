class CustomerFilesController < ApplicationController
	
	respond_to :html
	
	before_filter :authenticate_user!
	
	# Side effect: loads @customer_files or @customer_file as appropriate.
	# e.g., for index action, @customer_files is set to CustomerFile.accessible_by(current_ability)
	# For actions specified by the :new option, a new customer_file will be built rather than fetching one.
	load_and_authorize_resource

	# GET /customer_files
	def index
		respond_with @customer_files
	end
	
	# GET /customer_files/:id
	def show
		respond_with @customer_file
	end
	
	# GET /customer_files/:id/new_charge
	def new_charge
		respond_with @customer_file
	end
	
	# PUT /customer_files/:id/create_charge
	def create_charge
		respond_with @customer_file do |format|
			if @customer_file.create_charge(params[:customer_file])
				set_flash_message :notice, :created_charge
			else
				format.html { render :new_charge }
			end
		end
	end
end
