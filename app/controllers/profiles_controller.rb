class ProfilesController < ApplicationController
	
	respond_to :html, :js, :json
	
	before_filter :authenticate_user_on_public_site, except: [:show, :show_claiming, :link_index, :search, :about_payments]
	before_filter :authenticate_user_on_private_site, except: :show
	
	before_filter :load_user_and_profile, only: [:view_my_profile, :edit_my_profile]
	
	# Side effect: loads @profiles or @profile as appropriate.
	# e.g., for index action, @profiles is set to Profile.accessible_by(current_ability)
	load_and_authorize_resource new: :admin
	skip_load_resource only: [:view_my_profile, :edit_my_profile, :autocomplete_service_name, :no_categories, :no_subcategories, :no_services]
	skip_load_and_authorize_resource only: [:search, :autocomplete_specialty_name, :autocomplete_location_city]
	
	# Notify profile moderator when profile has been update by profile owner
	after_filter :notify_profile_moderator, only: [:formlet_update, :photo_update]
	
	# *After* profile is loaded:
	#   ensure it has at least one location
	#   set SEO description and keywords for profile show and edit pages
	#   ensure there is a new review for the admin profile edit page
	before_filter :require_location_in_profile, only: [:new, :edit, :edit_tab, :edit_my_profile, :edit_plain]
	before_filter :seo_keywords, only: [:edit, :show, :edit_my_profile, :view_my_profile]
	before_filter :seo_description, only: [:edit, :show, :edit_my_profile, :view_my_profile]
	before_filter :require_new_review, only: :edit_plain
	
	# Autocomplete service and specialty names.
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
		@order_by_options = { recent: 'recent', last_name: 'last name' }
		@profiles = @profiles.with_admin_notes if can?(:manage, Profile) && params[:with_admin_notes].present?
		case params[:order_by]
		when 'recent'
			@profiles = @profiles.order_by_descending_id
		when 'last_name'
			@profiles = @profiles.order_by_last_name
		else
			@profiles = @profiles.order_by_id
		end
		@profiles = @profiles.page(params[:page]).per(params[:per_page])
		render layout: 'plain'
	end
	
	def no_categories
		@profiles = paged_profiles_with_no CategoryProfile
		render layout: 'plain'
	end
	
	def no_subcategories
		@profiles = paged_profiles_with_no ProfileSubcategory
		render layout: 'plain'
	end
	
	def no_services
		@profiles = paged_profiles_with_no ProfileService
		render layout: 'plain'
	end
	
	def link_index
		@profiles = @profiles.order_by_id.page(params[:page]).per(params[:per_page])
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
		if @profile.update_attributes(profile_params)
			set_flash_message :notice, :updated
			redirect_to profile_url @profile
		else
			require_new_review # For rendering the new review form.
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
			@refresh_partials = params[:refresh_partials]
			@child_formlet = params[:child_formlet]
			@update_succeeded = @profile.update_attributes(profile_params)
		end
		respond_with @profile, layout: false
	end

	def photo_update
		begin
			if params[:source_url]
				begin
					@profile.profile_photo = URI.parse(params[:source_url])
				rescue
					render json: {:error => 'true',
							:error_array => [get_error_message('profile_photo_source_url_error')]} and return
				end
			elsif params[:file]
				@profile.profile_photo = params[:file]
			else
				head :bad_request
				return
			end

			if @profile.save
				if @profile.profile_photo.exists?
					render json: {:profile_photo_src =>  @profile.profile_photo.url(:original)}
				else
					head :bad_request
					return
				end 
			else
				error_array = Array.new
				if @profile.errors[:profile_photo_file_size].present?
					error_message = get_error_message :profile_photo_filesize_error_html
					error_array.push(error_message) if error_message
				end
				if @profile.errors[:profile_photo_content_type].present?
					error_message = get_error_message :profile_photo_filetype_error
					error_array.push(error_message) if error_message
				end
				render json: {:error => 'true', :error_array => error_array}
			end
		rescue Exception => exc
			logger.error "Profile.save failed during photo upload: #{exc.message}"
			render json: {:error => 'true', :profile_id =>  @profile.id,
				:error_array => [(get_error_message(exc.is_a?(Timeout::Error) ? 'profile_photo_processing_timeout_html' : 'profile_photo_upload_generic_error_html'))]}
		end
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
		@search_service = Service.find_by_id params[:service_id].to_i if params[:service_id].present?
		options[:search_area_tag_id] = @search_area_tag_id = params[:search_area_tag_id]
		if params[:latitude].present? && params[:longitude].present?
			@search_latitude, @search_longitude = params[:latitude], params[:longitude]
			options[:order_by_distance] = { latitude: @search_latitude, longitude: @search_longitude }
		elsif params[:address].present?
			@search_address = params[:address]
			options[:address] = @search_address
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
		@search = if @search_service && (@search_query.blank? || @search_query == @search_service.name)
			Profile.search_by_service @search_service, options
		else
			@search_service = nil # In case the user switched from search-by-service to full-text search.
			Profile.fuzzy_search @search_query, options
		end
		render :search_results
	end
	
	def new_invitation
		render layout: 'plain'
	end
	
	def send_invitation
		@subject, @body = params[:subject], params[:body]
		test_invitation = (params[:commit] == t('views.profile.edit.invitation_preview_button'))
		email = test_invitation.present? ? current_user.email : nil
		if @profile.update_attributes(profile_params) && @profile.invite(@subject, @body, sender: current_user, preview_email: email)
			set_flash_message :notice, :invitation_sent, recipient: (email.presence || @profile.invitation_email)
			if test_invitation.present?
				render action: :new_invitation, layout: 'plain'
				flash[:notice] = nil
			else
				redirect_to profile_url @profile
			end
		else
			set_flash_message :alert, :invitation_error
			render action: :new_invitation, layout: 'plain'
		end
	end

	def rating_score
		render layout: false
	end

	def edit_rating
		render layout: false
	end
	
	def rate
		respond_to do |format|
			success = !!@profile.try(:rate, params[:score], current_user)
			set_flash_message :alert, :rate_error unless success
			format.html { redirect_to new_review_for_profile_url @profile }
			format.json { render json: {success: success} }
		end
	end
	
	def services_info
		info = { maps: {}, names: {}, ids_names: {} }
		info[:maps]['services'], info[:names]['services'] = @profile.categories_services_info
		info[:maps]['specialties'], info[:names]['specialties'] = @profile.services_specialties_info
		info[:ids_names]['services'] = @profile.service_ids_names
		info[:ids_names]['specialties'] = @profile.specialty_ids_names
		respond_with info
	end
	
	def show_tab
		render layout: false
	end
	
	def edit_tab
		render layout: false
	end
	
	private
	
	# Load the user and profile instance variables.
	def load_user_and_profile
		@user = current_user
		@user.load_profile
		@profile = @user.profile
	end
	
	def seo_keywords
		@meta_keywords = [@meta_keywords,
			@profile.categories.map(&:lower_case_name),
			@profile.subcategories.map(&:lower_case_name),
			@profile.services.map(&:lower_case_name),
			@profile.specialties.map(&:lower_case_name)].flatten.compact.uniq.join(', ')
	end
	
	def seo_description
		@meta_description = [@meta_description,
			@profile.company_name.presence,
			@profile.presentable_display_name.presence,
			@profile.headline.presence
		].compact.uniq.join(' - ')
	end
	
	# Create a new review of this provider.  Used by the admin edit page.
	def require_new_review
		@review = @profile.reviews.build
	end

	# Send email notification to profile moderator
	def notify_profile_moderator
		if @profile.errors.empty? && !current_user.profile_editor?
			AdminMailer.on_update_alert(@profile).deliver
		end
	end
	
	def paged_profiles_with_no(type)
		Profile.where('id NOT IN(?)', type.group(:profile_id).select(:profile_id).map(&:profile_id)).page(params[:page]).per(params[:per_page])
	end
	
	# Use this method to whitelist the permissible parameters. Example:
	# params.require(:person).permit(:name, :age)
	# Also, you can specialize this method with per-user checking of permissible attributes.
	def profile_params
		permitted_locations_attributes = Location::DEFAULT_ACCESSIBLE_ATTRIBUTES + [:id, :_destroy]
		permitted_profile_announcements_attributes = ProfileAnnouncement::DEFAULT_ACCESSIBLE_ATTRIBUTES + [:id, :_destroy]
		if [:admin, :profile_editor].include?(updater_role)
			params.require(:profile).permit(*Profile::EDITOR_ACCESSIBLE_ATTRIBUTES,
				locations_attributes: permitted_locations_attributes,
				profile_announcements_attributes: permitted_profile_announcements_attributes)
		else
			params.require(:profile).permit(*Profile::DEFAULT_ACCESSIBLE_ATTRIBUTES,
				locations_attributes: permitted_locations_attributes,
				profile_announcements_attributes: permitted_profile_announcements_attributes)
		end
	end
end
