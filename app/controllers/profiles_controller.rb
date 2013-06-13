class ProfilesController < ApplicationController
	
	respond_to :html, :js
	
	before_filter :authenticate_user!, except: [:index, :show, :show_claiming, :link_index, :search]
	
	before_filter :create_profile_if_needed, only: [:view_my_profile, :edit_my_profile]
	
	# Side effect: loads @profiles or @profile as appropriate.
	# e.g., for index action, @profiles is set to Profile.accessible_by(current_ability)
	load_and_authorize_resource new: :admin
	skip_load_resource only: [:view_my_profile, :edit_my_profile]
	skip_load_and_authorize_resource only: [:search, :autocomplete_service_name, :autocomplete_specialty_name, :autocomplete_location_city]
	
	# *After* profile is loaded:
	#   ensure it has at least one location
	#   set publish state based on parameter
	#   set SEO keywords for profile show page
	before_filter :require_location_in_profile, only: [:new, :edit, :edit_my_profile, :edit_plain]
	before_filter :process_profile_admin_params, only: [:create, :update]
	before_filter :seo_keywords, only: :show
	
	# Autocomplete custom service and specialty names.
	autocomplete :service, :name, full: true
	autocomplete :specialty, :name, full: true
	
	# Auto-complete city name in location record.
	# The database will have many records with the same city, so retrieve from database by distinct city.
	# In order for the distinct city selection to work, use the :full_model option to
	# trick autocomplete into not selecting specific columns.
	# We can change the size limit on the returned list with the :limit option.
	autocomplete :location, :city, scopes: [:unique_by_city], full_model: true
	# Similar unique auto-completion for profile lead_generator.
	autocomplete :profile, :lead_generator, scopes: [:unique_by_lead_generator], full_model: true
	
	def index
		@profiles = @profiles.with_admin_notes if current_user.try(:admin?) && params[:with_admin_notes].present?
		@profiles = @profiles.order_by_last_name.page params[:page]
		render layout: 'plain'
	end
	
	def link_index
		@profiles = @profiles.order_by_id.page params[:page]
		render layout: 'plain'
	end
	
	def admin
		render layout: 'plain'
	end
	
	def new
		render layout: 'plain'
	end
	
	def create
		# @profile initialized by load_and_authorize_resource with cancan ability conditions and then parameter values.
		if @profile.save
			set_flash_message :notice, :created
			redirect_to(params[:admin] ? edit_profile_url(@profile) : profile_url(@profile))
		else
			set_flash_message :alert, :create_error
			render action: (params[:admin] ? :admin : :new), layout: 'plain'
		end
	end
	
	def show_plain
		render layout: 'plain'
	end
	
	def edit_plain
		render layout: 'plain'
	end
	
	def update
		if @profile.update_attributes(params[:profile])
			set_flash_message :notice, :updated
			redirect_to profile_url @profile
		else
			set_flash_message :alert, :update_error
			render action: :edit_plain, layout: 'plain'
		end
	end
	
	def formlet_update
		@formlet = params[:formlet]
		if @formlet.blank?
			set_flash_message :alert, :update_error
		else
			@refresh_formlets = params[:refresh_formlets]
			@update_succeeded = @profile.update_attributes(params[:profile])
		end
		respond_with @profile, layout: false
	end
	
	# CanCan should prevent access to this action if the profile has been claimed.
	def destroy
		@profile.destroy
		set_flash_message :notice, :destroyed
		redirect_to admin_profiles_url
	end
	
	# We are showing a provider their profile.  The token can be used to claim the profile.
	# Purpose of this action: to give a provider a preview of their profile before they claim it.
	def show_claiming
		@show_claiming_token = params[:token]
		render action: :show
	end
	
	def view_my_profile
		@claim_token = params[:claim_token] # Exists if we are confirming replacement of current profile with a claimed one.
		render action: :show
	end
	
	def edit_my_profile
		render action: :edit
	end
	
	def search
		options = {}
		@search_query = params[:query]
		options[:search_area_tag_id] = @search_area_tag_id = params[:search_area_tag_id]
		if params[:latitude].present? && params[:longitude].present?
			@search_latitude, @search_longitude = params[:latitude], params[:longitude]
			options[:order_by_distance] = { latitude: @search_latitude, longitude: @search_longitude }
		elsif params[:city].present? && params[:region].present?
			@search_city = params[:city]
			@search_region = params[:region]
			options[:location] = Location.new(city: @search_city, region: @search_region)
		elsif params[:postal_code].present?
			@search_postal_code = params[:postal_code]
			options[:location] = Location.new(postal_code: @search_postal_code)
		end
		@search_page = ((options[:page] = params[:page]).presence || 1).to_i
		@search_per_page = options[:per_page] = params[:per_page].to_i if params[:per_page].present?
		options[:published_only] = !current_user.try(:profile_editor?)
		@search = Profile.fuzzy_search @search_query, options
		render :search_results
	end
	
	def new_invitation
		render layout: 'plain'
	end
	
	def send_invitation
		if @profile.update_attributes(params[:profile]) && @profile.invite
			set_flash_message :notice, :invitation_sent
			redirect_to profile_url @profile
		else
			set_flash_message :alert, :invitation_error
			render action: :new_invitation, layout: 'plain'
		end
	end
	
	def rating_score
		render layout: false
	end
	
	def rate
		render json: !!@profile.try(:rate, params[:score], current_user)
	end
	
	private
	
	def set_up_profile(method=:build_profile)
		@user = current_user
		if @user.is_provider?
			@user.send method unless @user.profile
			@profile = @user.profile
		end
	end
	
	def create_profile_if_needed
		set_up_profile :create_profile
	end
	
	def seo_keywords
		@meta_keywords = [@meta_keywords,
			@profile.categories.map(&:lower_case_name),
			@profile.services.map(&:lower_case_name),
			@profile.specialties.map(&:lower_case_name)].flatten.compact.uniq.join(', ')
	end
end
