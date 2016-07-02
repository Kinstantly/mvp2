class StoryTeasersController < ApplicationController
	layout 'plain'
	
	before_action :authenticate_user!
	
	# @story_teaser and @story_teasers initialized by load_and_authorize_resource with cancan ability conditions.
	load_and_authorize_resource
	
	# GET /story_teasers
	# GET /story_teasers.json
	def index
		@story_teasers = @story_teasers.order_by_active_display_order.page(params[:page]).per(params[:per_page])
		respond_to do |format|
			format.html # index.html.haml
			format.json { render json: @story_teasers }
		end
	end

	# GET /story_teasers/1
	# GET /story_teasers/1.json
	def show
		respond_to do |format|
			format.html # show.html.haml
			format.json { render json: @story_teaser }
		end
	end

	# GET /story_teasers/new
	# GET /story_teasers/new.json
	def new
		respond_to do |format|
			format.html # new.html.haml
			format.json { render json: @story_teaser }
		end
	end

	# GET /story_teasers/1/edit
	def edit
	end

	# POST /story_teasers
	# POST /story_teasers.json
	def create
		respond_to do |format|
			if @story_teaser.save
				format.html { redirect_to @story_teaser, notice: 'Story teaser was successfully created.' }
				format.json { render json: @story_teaser, status: :created, location: @story_teaser }
			else
				format.html { render action: "new" }
				format.json { render json: @story_teaser.errors, status: :unprocessable_entity }
			end
		end
	end

	# PATCH/PUT /story_teasers/1
	# PATCH/PUT /story_teasers/1.json
	def update
		respond_to do |format|
			if @story_teaser.update_attributes(story_teaser_params)
				format.html { redirect_to @story_teaser, notice: 'Story teaser was successfully updated.' }
				format.json { head :no_content }
			else
				format.html { render action: "edit" }
				format.json { render json: @story_teaser.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /story_teasers/1
	# DELETE /story_teasers/1.json
	def destroy
		@story_teaser.destroy

		respond_to do |format|
			format.html { redirect_to story_teasers_url }
			format.json { head :no_content }
		end
	end

	private

		# Use this method to whitelist the permissible parameters. Example:
		# params.require(:person).permit(:name, :age)
		# Also, you can specialize this method with per-user checking of permissible attributes.
		def story_teaser_params
			params.require(:story_teaser).permit(*StoryTeaser::DEFAULT_ACCESSIBLE_ATTRIBUTES)
		end
end
