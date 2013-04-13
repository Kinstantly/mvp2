class ProfilesController < ApplicationController
	before_filter :authenticate_user!, except: [:index, :show, :link_index, :search]
	
	# Side effect: loads @profiles or @profile as appropriate.
	# e.g., for index action, @profiles is set to Profile.accessible_by(current_ability)
	load_and_authorize_resource new: :admin
	skip_load_and_authorize_resource only: [:search, :autocomplete_service_name, :autocomplete_specialty_name, :autocomplete_location_city]
	
	# *After* profile is loaded:
	#   ensure it has at least one location
	#   set publish state based on parameter
	before_filter :require_location_in_profile, only: [:new, :edit]
	before_filter :process_profile_admin_params, only: [:create, :update]
	
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
		@profiles = @profiles.order('lower(last_name)').page params[:page]
	end
	
	def link_index
		@profiles = @profiles.page params[:page]
	end
	
	def create
		# @profile initialized by load_and_authorize_resource with cancan ability conditions and then parameter values.
		if @profile.save
			set_flash_message :notice, :profile_created
			redirect_to(params[:admin] ? edit_profile_path(@profile) : profile_path(@profile))
		else
			set_flash_message :alert, :profile_create_error
			render action: (params[:admin] ? :admin : :new)
		end
	end
	
	def update
		if @profile.update_attributes(params[:profile])
			set_flash_message :notice, :profile_updated
			redirect_to profile_path @profile
		else
			set_flash_message :alert, :profile_update_error
			render action: :edit
		end
	end
	
	# CanCan should prevent access to this action if the profile has been claimed.
	def destroy
		@profile.destroy
		set_flash_message :notice, :profile_destroyed
		redirect_to admin_profiles_path
	end
	
	def search
		options = {}
		@search_query = params[:query]
		options[:search_area_tag_id] = @search_area_tag_id = params[:search_area_tag_id]
		if params[:latitude].present? && params[:longitude].present?
			options[:order_by_distance] = { latitude: params[:latitude], longitude: params[:longitude] }
		elsif params[:city].present? && params[:region].present?
			@search_city = params[:city]
			@search_region = params[:region]
			options[:location] = Location.new(city: @search_city, region: @search_region)
		elsif params[:postal_code].present?
			@search_postal_code = params[:postal_code]
			options[:location] = Location.new(postal_code: @search_postal_code)
		end
		options[:published_only] = !current_user.try(:profile_editor?)
		@search = Profile.fuzzy_search @search_query, options
		render :search_results
	end
	
	def send_invitation
		if @profile.update_attributes(params[:profile]) && @profile.invite
			set_flash_message :notice, :invitation_sent
			redirect_to profile_path @profile
		else
			set_flash_message :alert, :invitation_error
			render action: :new_invitation
		end
	end
	
	def rate
		render json: !!@profile.try(:rate, params[:score], current_user)
	end
end
