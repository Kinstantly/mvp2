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
			if @contact_blocker.update_attributes_from_email_delivery params[:contact_blocker]
				redirect_to contact_blocker_confirmation_url
			else
				render action: :new_from_email_delivery
			end
		else
			redirect_to email_delivery_not_found_url
		end
	end
	
	# GET /contact_blockers
	# GET /contact_blockers.json
	def index
		@contact_blockers = ContactBlocker.all

		respond_to do |format|
			format.html # index.html.erb
			format.json { render json: @contact_blockers }
		end
	end

	# GET /contact_blockers/1
	# GET /contact_blockers/1.json
	def show
		@contact_blocker = ContactBlocker.find(params[:id])

		respond_to do |format|
			format.html # show.html.erb
			format.json { render json: @contact_blocker }
		end
	end

	# GET /contact_blockers/new
	# GET /contact_blockers/new.json
	def new
		@contact_blocker = ContactBlocker.new

		respond_to do |format|
			format.html # new.html.erb
			format.json { render json: @contact_blocker }
		end
	end

	# GET /contact_blockers/1/edit
	def edit
		@contact_blocker = ContactBlocker.find(params[:id])
	end

	# POST /contact_blockers
	# POST /contact_blockers.json
	def create
		@contact_blocker = ContactBlocker.new(params[:contact_blocker])

		respond_to do |format|
			if @contact_blocker.save
				format.html { redirect_to @contact_blocker, notice: 'Contact blocker was successfully created.' }
				format.json { render json: @contact_blocker, status: :created, location: @contact_blocker }
			else
				format.html { render action: "new" }
				format.json { render json: @contact_blocker.errors, status: :unprocessable_entity }
			end
		end
	end

	# PUT /contact_blockers/1
	# PUT /contact_blockers/1.json
	def update
		@contact_blocker = ContactBlocker.find(params[:id])

		respond_to do |format|
			if @contact_blocker.update_attributes(params[:contact_blocker])
				format.html { redirect_to @contact_blocker, notice: 'Contact blocker was successfully updated.' }
				format.json { head :no_content }
			else
				format.html { render action: "edit" }
				format.json { render json: @contact_blocker.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /contact_blockers/1
	# DELETE /contact_blockers/1.json
	def destroy
		@contact_blocker = ContactBlocker.find(params[:id])
		@contact_blocker.destroy

		respond_to do |format|
			format.html { redirect_to contact_blockers_url }
			format.json { head :no_content }
		end
	end
	
	private
	
	def load_from_email_delivery
		if (token = params[:email_delivery_token]).present? and (email_delivery = EmailDelivery.find_by_token token)
			@contact_blocker = email_delivery.contact_blockers.build email: email_delivery.recipient
		end
	end
end
