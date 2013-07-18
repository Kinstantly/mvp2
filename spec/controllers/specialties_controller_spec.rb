require 'spec_helper'

describe SpecialtiesController do
	
	context "as non-admin user" do
		it "should have no access to the specialties listing" do
			get :index
			response.should_not render_template('index')
		end
		
		it "cannot create a specialty" do
			post :create, specialty: FactoryGirl.attributes_for(:predefined_specialty, name: 'making chile verde')
			Specialty.find_by_name('making chile verde').should be_nil
		end
		
		it "cannot update a specialty" do
			specialty = FactoryGirl.create(:predefined_specialty, name: 'steaming tamales')
			put :update, id: specialty.id,
				specialty: FactoryGirl.attributes_for(:predefined_specialty, name: 'making chile verde')
			Specialty.find_by_name('making chile verde').should be_nil
			Specialty.find_by_name('steaming tamales').should_not be_nil
		end
	end
	
	context "as admin user" do
		before (:each) do
			@admin = FactoryGirl.create(:admin_user, email: 'admin@example.com')
			sign_in @admin
		end
		
		describe "GET 'index'" do
			before(:each) do
				FactoryGirl.create(:predefined_specialty, name: 'making chile verde')
				get :index
			end
		
			it "renders the view" do
				response.should render_template('index')
			end
		
			it "assigns @specialties" do
				assigns[:specialties].should == Specialty.all
			end
		end
	
		describe "GET 'new'" do
			before(:each) do
				get :new
			end
		
			it "renders the view" do
				response.should render_template('new')
			end
		
			it "assigns @specialty" do
				assigns[:specialty].should_not be_nil
			end
		end
		
		describe "POST 'create'" do
			it "successfully creates the specialty" do
				post :create, specialty: FactoryGirl.attributes_for(:predefined_specialty, name: 'making chile verde')
				response.should redirect_to(controller: :specialties, action: :edit, id: assigns[:specialty].id)
			end
		
			it "successfully adds search terms upon creation" do
				post :create, specialty: FactoryGirl.attributes_for(:predefined_specialty, name: 'making chile verde',
					search_term_names_to_add: ['green chile', 'chile verde'])
				assigns[:specialty].search_terms.find_by_name('green chile').should_not be_nil
				assigns[:specialty].search_terms.find_by_name('chile verde').should_not be_nil
			end
		end
	
		describe "GET 'edit'" do
			before(:each) do
				@specialty = FactoryGirl.create(:predefined_specialty, name: 'steaming tamales')
				get :edit, id: @specialty.id
			end
		
			it "renders the view" do
				response.should render_template('edit')
			end
		
			it "assigns @specialty" do
				assigns[:specialty].should == @specialty
			end
		end
		
		describe "PUT 'update'" do
			before(:each) do
				@specialty = FactoryGirl.create(:predefined_specialty, name: 'steaming tamales',
					search_terms: [FactoryGirl.create(:search_term, name: 'carne adovada')])
			end
			
			it "successfully updates the specialty" do
				put :update, id: @specialty.id,
					specialty: FactoryGirl.attributes_for(:predefined_specialty, name: 'making chile verde')
				response.should redirect_to(controller: :specialties, action: :edit, id: assigns[:specialty].id)
				assigns[:specialty].name.should == 'making chile verde'
			end
		
			it "successfully adds search terms upon update" do
				put :update, id: @specialty.id, specialty: FactoryGirl.attributes_for(:predefined_specialty,
					search_term_names_to_add: ['green chile', 'chile verde'])
				assigns[:specialty].search_terms.find_by_name('green chile').should_not be_nil
				assigns[:specialty].search_terms.find_by_name('chile verde').should_not be_nil
			end
		
			it "preserves search term upon update" do
				put :update, id: @specialty.id,
					specialty: FactoryGirl.attributes_for(:predefined_specialty, name: 'making chile verde')
				assigns[:specialty].search_terms.find_by_name('carne adovada').should_not be_nil
			end
		
			it "successfully removes a search term upon update" do
				put :update, id: @specialty.id, specialty: FactoryGirl.attributes_for(:predefined_specialty,
					search_term_ids_to_remove: ['carne adovada'.to_search_term.id])
				assigns[:specialty].search_terms.find_by_name('carne adovada').should be_nil
			end
		end
	end
	
end
