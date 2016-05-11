require 'spec_helper'

describe SpecialtiesController, :type => :controller do
	
	context "as non-admin user" do
		it "should have no access to the specialties listing" do
			get :index
			expect(response).not_to render_template('index')
		end
		
		it "cannot create a specialty" do
			post :create, specialty: FactoryGirl.attributes_for(:predefined_specialty, name: 'making chile verde')
			expect(Specialty.find_by_name('making chile verde')).to be_nil
		end
		
		it "cannot update a specialty" do
			specialty = FactoryGirl.create(:predefined_specialty, name: 'steaming tamales')
			put :update, id: specialty.id,
				specialty: FactoryGirl.attributes_for(:predefined_specialty, name: 'making chile verde')
			expect(Specialty.find_by_name('making chile verde')).to be_nil
			expect(Specialty.find_by_name('steaming tamales')).not_to be_nil
		end
	end
	
	context "as admin user" do
		let(:admin) { FactoryGirl.create(:admin_user, email: 'admin@example.com') }
		
		before (:each) do
			sign_in admin
		end
		
		describe "GET 'index'" do
			before(:example) do
				FactoryGirl.create(:predefined_specialty, name: 'making chile verde')
				get :index
			end
		
			it "renders the view" do
				expect(response).to render_template('index')
			end
		
			it "assigns @specialties" do
				Specialty.all.each do |specialty|
					expect(assigns[:specialties]).to include specialty
				end
			end
		end
	
		describe "GET 'new'" do
			before(:example) do
				get :new
			end
		
			it "renders the view" do
				expect(response).to render_template('new')
			end
		
			it "assigns @specialty" do
				expect(assigns[:specialty]).not_to be_nil
			end
		end
		
		describe "POST 'create'" do
			it "successfully creates the specialty" do
				post :create, specialty: FactoryGirl.attributes_for(:predefined_specialty, name: 'making chile verde')
				expect(response).to redirect_to(controller: :specialties, action: :edit, id: assigns[:specialty].id)
			end
		
			it "successfully adds search terms upon creation" do
				post :create, specialty: FactoryGirl.attributes_for(:predefined_specialty, name: 'making chile verde',
					search_term_names_to_add: ['green chile', 'chile verde'])
				expect(assigns[:specialty].search_terms.find_by_name('green chile')).not_to be_nil
				expect(assigns[:specialty].search_terms.find_by_name('chile verde')).not_to be_nil
			end
		end
	
		describe "GET 'edit'" do
			let(:specialty) { FactoryGirl.create(:predefined_specialty, name: 'steaming tamales') }
			
			before(:example) do
				get :edit, id: specialty.id
			end
		
			it "renders the view" do
				expect(response).to render_template('edit')
			end
		
			it "assigns @specialty" do
				expect(assigns[:specialty]).to eq specialty
			end
		end
		
		describe "PUT 'update'" do
			let(:specialty) { 
				FactoryGirl.create(:predefined_specialty, name: 'steaming tamales',
					search_terms: [FactoryGirl.create(:search_term, name: 'carne adovada')])
			}
			
			it "successfully updates the specialty" do
				put :update, id: specialty.id,
					specialty: FactoryGirl.attributes_for(:predefined_specialty, name: 'making chile verde')
				expect(response).to redirect_to(controller: :specialties, action: :edit, id: assigns[:specialty].id)
				expect(assigns[:specialty].name).to eq 'making chile verde'
			end
		
			it "successfully adds search terms upon update" do
				put :update, id: specialty.id, specialty: FactoryGirl.attributes_for(:predefined_specialty,
					search_term_names_to_add: ['green chile', 'chile verde'])
				expect(assigns[:specialty].search_terms.find_by_name('green chile')).not_to be_nil
				expect(assigns[:specialty].search_terms.find_by_name('chile verde')).not_to be_nil
			end
		
			it "preserves search term upon update" do
				put :update, id: specialty.id,
					specialty: FactoryGirl.attributes_for(:predefined_specialty, name: 'making chile verde')
				expect(assigns[:specialty].search_terms.find_by_name('carne adovada')).not_to be_nil
			end
		
			it "successfully removes a search term upon update" do
				put :update, id: specialty.id, specialty: FactoryGirl.attributes_for(:predefined_specialty,
					search_term_ids_to_remove: ['carne adovada'.to_search_term.id])
				expect(assigns[:specialty].search_terms.find_by_name('carne adovada')).to be_nil
			end
		end
	end
	
end
