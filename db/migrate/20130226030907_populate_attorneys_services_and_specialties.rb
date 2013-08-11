class PopulateAttorneysServicesAndSpecialties < ActiveRecord::Migration
	class Category < ActiveRecord::Base
		has_and_belongs_to_many :services
	end

	class Service < ActiveRecord::Base
		has_and_belongs_to_many :categories
		has_and_belongs_to_many :specialties
	end

	class Specialty < ActiveRecord::Base
		has_and_belongs_to_many :services
	end

	def up
		Category.reset_column_information
		Service.reset_column_information
		Specialty.reset_column_information
		parse_lines.each do |cat_name, svcs|
			cat = predefine(Category.where(name: cat_name).first_or_create)
			svcs.each do |svc_name, specs|
				svc = predefine(Service.where(name: svc_name).first_or_create)
				cat.services << svc unless cat.services.include?(svc)
				specs.each do |spec_name|
					spec = predefine(Specialty.where(name: spec_name).first_or_create)
					svc.specialties << spec unless svc.specialties.include?(spec)
				end
			end
		end
	end

	# Leave categories in place.
	def down
		Category.reset_column_information
		Service.reset_column_information
		Specialty.reset_column_information
		parse_lines.each do |cat_name, svcs|
			svcs.each do |svc_name, specs|
				specs.each do |spec_name|
					Specialty.where(name: spec_name).first_or_create.destroy
				end
				svc = Service.where(name: svc_name).first_or_create
				svc.destroy if svc.specialties.blank?
			end
			# cat = Category.where(name: cat_name).first_or_create
			# cat.destroy if cat.services.blank?
		end
	end
	
	def parse_lines
		load_lines
		names = {}
		@lines.strip.split("\n").each do |line|
			cat, svc, specs, comments = line.strip.split(';')
			cat.strip!
			svc.strip!
			names[cat] ||= {}
			names[cat][svc] ||= []
			# Split specialty names on commas. Ignore and remove escaped commas.
			specs.strip.split(/(?<!\\),/).each do |spec|
				spec.strip!
				spec.delete!("\\")
				names[cat][svc] << spec unless names[cat][svc].include?(spec)
			end if specs
		end
		names
	end
	
	def predefine(record)
		unless record.is_predefined
			record.is_predefined = true
			record.save
		end
		record
	end
	
	def load_lines
		@lines = <<'eof'
ATTORNEYS;adoption attorneys;agency adoption, independent adoption, domestic partner adoptions, international adoption, single parent adoption, stepparent adoption;
ATTORNEYS;family law attorneys;appeals, bullying, child custody, child support, civil rights litigation, conservatorship, divorce, domestic violence, expulsions, guardianship, juvenile court proceedings, special education, special needs trusts, suspensions;
ATTORNEYS;special needs attorneys;appeals, disciplinary matters, consultations, due process hearings, Individual Education Placement (IEP) meetings, mediation, public school placements, private placements through public schools;
ATTORNEYS;juvenile law attorneys;appeals, juvenile court proceedings;
ATTORNEYS;child support collection attorneys;appeals;
ATTORNEYS;child custody attorneys;appeals, custody disputes, legal custody, physical custody;
eof
	end
end
