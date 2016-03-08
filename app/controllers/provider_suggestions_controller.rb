class ProviderSuggestionsController < ApplicationController
	
	respond_to :html, :js
	
	before_filter :authenticate_user_on_public_site, except: [:new, :create]
	before_filter :authenticate_user_on_private_site
	
	# Side effect: loads @provider_suggestions or @provider_suggestion as appropriate.
	# e.g., for index action, @provider_suggestions is set to ProviderSuggestion.accessible_by(current_ability)
	# For actions specified by the :new option, a new provider_suggestion will be built rather than fetching one.
	load_and_authorize_resource

	# GET /provider_suggestions/new
	def new
		respond_with @provider_suggestion, layout: false
	end
	
	# POST /provider_suggestions
	def create
		@provider_suggestion.suggester = current_user if user_signed_in?
		@provider_suggestion.save
		respond_with @provider_suggestion, layout: false
	end
	
	def index
		@provider_suggestions = @provider_suggestions.order_by_descending_id.page(params[:page]).per(params[:per_page])
		render layout: 'plain'
	end
	
	def show
		render layout: 'plain'
	end
	
	def edit
		render layout: 'plain'
	end
	
	# PUT /provider_suggestions/1
	def update
		if @provider_suggestion.update_attributes provider_suggestion_params
			set_flash_message :notice, :updated
			respond_with @provider_suggestion
		else
			set_flash_message :alert, :update_error
			render action: :edit, layout: 'plain'
		end
	end

	# DELETE /provider_suggestions/1
	def destroy
		@provider_suggestion.destroy
		if @provider_suggestion.destroyed?
			set_flash_message :notice, :destroyed, name: @provider_suggestion.provider_name
		else
			set_flash_message :alert, :destroy_error, name: @provider_suggestion.provider_name
		end
		respond_with @provider_suggestion
	end
	
	private
	
	# Use this method to whitelist the permissible parameters. Example:
	# params.require(:person).permit(:name, :age)
	# Also, you can specialize this method with per-user checking of permissible attributes.
	def provider_suggestion_params
		if [:admin].include?(updater_role)
			params.require(:provider_suggestion).permit(*ProviderSuggestion::EDITOR_ACCESSIBLE_ATTRIBUTES)
		else
			params.require(:provider_suggestion).permit(*ProviderSuggestion::DEFAULT_ACCESSIBLE_ATTRIBUTES)
		end
	end
end
