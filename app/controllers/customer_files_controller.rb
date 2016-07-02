class CustomerFilesController < ApplicationController
	
	respond_to :html
	
	before_action :authenticate_user!
	
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
			if @customer_file.create_charge(customer_file_params)
				set_flash_message :notice, :created_charge
			else
				format.html { render :new_charge }
			end
		end
	end
	
	private
	
	# Use this method to whitelist the permissible parameters. Example:
	# params.require(:person).permit(:name, :age)
	# Also, you can specialize this method with per-user checking of permissible attributes.
	def customer_file_params
		params.require(:customer_file).permit(*CustomerFile::DEFAULT_ACCESSIBLE_ATTRIBUTES)
	end
end
