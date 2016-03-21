class PopulatePredefinedSpecialties < ActiveRecord::Migration
	@@specialties = ["abuse", "ADHD", "ADHD/executive function", "ADHD/impulsivity", "adoption", "adoption/divorce", "allergies and food sensitivities", "anger/stress management", "anxieties", "anxieties/phobias", "attachment", "autism-spectrum disorders", "autism/Asperger's", "babysitting", "bedwetting", "behavior", "behavior disabilities", "birth defects", "breastfeeding", "feeding", "child-proofing/home safety", "choosing a pre-school", "choosing a school", "choosing a school (pre-K to 12)", "co-parenting", "college admissions", "college admissions/essays", "college financial aid", "couple's therapy", "couples/family therapy", "cutting/self-injury", "depression/mood", "depression/sadness", "developmental delay", "diabetes", "divorce", "divorce and kids", "drug/alcohol use", "eating disorders", "eating issues/disorder", "emotional disabilities", "family relationships/communication", "feeding", "feeding/nutrition", "fertility", "food allergies/sensitivities", "fussy eater/nutrition", "grocery shopping/food preparation", "home safety", "impulse control", "labor and delivery", "learning disabilities", "learning disorders", "M-CHAT developmental screening", "new-mom support", "obesity", "oncology (cancer)", "oppositional behavior", "osteoporosis", "parenting support", "peer relationships", "physical challenges", "physical disabilities", "positive discipline", "postpartum depression", "pre-school readiness", "reading/dyslexia", "rebellion", "renal disease", "school advocacy", "school difficulties", "school readiness", "school special needs advocacy", "self-injury/cutting", "sexual behavior", "sexuality and gender identity", "single-parenting", "sleep", "social phobias", "social problems/phobias", "speech", "sports injuries", "substance abuse", "toilet training", "Tourette's syndrome", "trauma", "weight issues", "weight management", "weight management/dieting"]
	
	class Specialty < ActiveRecord::Base
		# attr_accessible :name, :is_predefined
		has_and_belongs_to_many :profiles
		has_and_belongs_to_many :categories
	end
	
	def up
		Specialty.reset_column_information
		Specialty.all.each(&:destroy)
		@@specialties.each do |name|
			Specialty.create(name: name, is_predefined: true)
		end
	end

	def down
		Specialty.reset_column_information
		@@specialties.each do |name|
			c = Specialty.find_by_name name
			c.destroy if c
		end
	end
end
