class PopulateCategoriesServicesSpecialties < ActiveRecord::Migration
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
		load_lines
		clear_all
		@lines.strip.split("\n").each { |line|
			cat_name, svc_name, spec_names, comments = line.strip.split(';')
			cat = predefine(cat_name.strip.to_category)
			svc = predefine(svc_name.strip.to_service)
			cat.services << svc unless cat.services.include?(svc)
			# Split specialty names on commas. Ignore and remove escaped commas.
			spec_names.strip.split(/(?<!\\),/).each { |spec_name|
				spec = predefine(spec_name.strip.delete("\\").to_specialty)
				svc.specialties << spec unless svc.specialties.include?(spec)
			} if spec_names
		}
	end

	def down
		Category.reset_column_information
		Service.reset_column_information
		Specialty.reset_column_information
		clear_all
	end
	
	def clear_all
		Specialty.all.each(&:destroy)
		Service.all.each(&:destroy)
		Category.all.each(&:destroy)
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
THERAPISTS & PARENTING COACHES;addiction therapists;alcohol dependency, benzo abuse, day treatment, detox, drug dependency, heroin dependence, inhalant abuse, marijuana dependence, methamphetamine addiction, opiate replacement therapy, outpatient treatment, oxycontin abuse, residential treatment, prescription drug abuse, substance abuse, 12-step treatment;
THERAPISTS & PARENTING COACHES;applied behavior analysts/board-certified behavior analysts;aggression, autism spectrum, behavior modification, ;
THERAPISTS & PARENTING COACHES;child psychologists;abuse, ADHD, adoption, anger/stress management, anxieties/phobias, attachment, autism spectrum, bedwetting, behavior, choosing a school (pre-K to 12), co-parenting, depression/mood, developmental delay, divorce and kids, eating disorders, family relationships/communication, feeding, fussy eater, impulse control, learning disorders, neuro-psych assessment, oppositional behavior,  parent support, peer relationships, positive discipline, reading/dyslexia, school advocacy, school readiness, self injury/cutting, sexuality/gender identity, single-parenting, sleep, social skills, speech, substance abuse, toilet training, trauma, weight management;
THERAPISTS & PARENTING COACHES;child psychiatrists;abuse, anger/stress management, anxiety/phobias, ADHD, depression/mood, divorce and kids, eating disorders, family relationships/communication, impulse control, neuro-psych assessment, oppositional behavior, peer relationships, self-injury/cutting, sexuality/gender identity, single-parenting, substance abuse, trauma;
THERAPISTS & PARENTING COACHES;couples/family therapists;anger/stress management, co-parenting, discipline, divorce and kids, single parenting;
THERAPISTS & PARENTING COACHES;eating disorder therapists;anorexia, art therapy, binge eating, bulimia, cognitive behavioral therapy, compulsive overeating, music therapy, obesity, pica,  purging disorder, recreation therapy;
THERAPISTS & PARENTING COACHES;occupational therapists;ADHD, autism spectrum, behavioral/emotional regulation, coping strategies, feeding, handwriting, play, sensory processing, social skills;
THERAPISTS & PARENTING COACHES;parenting coaches;ADHD, adoption, anger/stress management, anxieties/phobias, attachment, autism spectrum, bedwetting, behavior, child-proofing/home safety, choosing a school (pre-K to 12), co-parenting, depression/mood, developmental delay, divorce and kids, eating disorders, family relationships/communication, feeding, fussy eater, impulse control, learning disorders, oppositional behavior,  parent support, peer relationships, positive discipline, reading/dyslexia, school advocacy, school readiness, self injury/cutting, sexuality/gender identity, single-parenting, sleep, speech, substance abuse, toilet training, trauma;
THERAPISTS & PARENTING COACHES;physical therapists;balance/coordination, cerebral palsy, developmental delays, endurance, fine motor skills, gross motor skills, sensory processing/integration, spinal bifada, strength, torticollis;
THERAPISTS & PARENTING COACHES;social skills therapists;Asperger's Syndrome, autism, group therapy, peer social skills;
THERAPISTS & PARENTING COACHES;speech therapists;ADHD, articulation disorders, autism, cleft palate, craniofacial anomalies, cranial nerve damage, developmental delay, DiGeorge Symdrome, Down's Syndrome, hearing loss, language delay, learning difficulties, motor speech disorders, pediatric traumatic brain injury, stammering/stuttering, stroke;
TUTORS & COUNSELORS;college admissions tutors/counselors;application guidance, athletes, choosing a college, essay review, financial aid, fine/performing arts, international students, learning disabled/ADHD, test prep, transfer students;
TUTORS & COUNSELORS;college financial aid counselors;government loans, private loans, scholarships, work-study programs;
TUTORS & COUNSELORS;executive function/time management tutors;ADHD, ;
TUTORS & COUNSELORS;languages tutors;assessments, Chinese, English as 2nd language, enrichment, French, German, learning disorders, phonics, reading/literacy issues, school advocacy, school readiness, Spanish, speech, study skills, test preparation;
TUTORS & COUNSELORS;math tutors;algebra, calculus, geometry, math (basic);
TUTORS & COUNSELORS;reading tutors;ADHD, assessments, autism spectrum, dyslexia, English as 2nd language, enrichment, learning disorders, phonics, reading/literacy issues, school advocacy, school readiness, speech, study skills, test preparation;
TUTORS & COUNSELORS;sciences tutors;anatomy, biology, chemistry, physics, science (basic);
TUTORS & COUNSELORS;study skills tutors;time management, ;
TUTORS & COUNSELORS;test prep tutors;ACT, SAT, ;
TUTORS & COUNSELORS;writing tutors;creative writing, essays, grammar,;
SPECIAL NEEDS;ADHD specialists;executive function, time management, ;
SPECIAL NEEDS;Asperger Syndrome;autism spectrum;
SPECIAL NEEDS;autism spectrum specialists;Asperger Syndrome, ;
SPECIAL NEEDS;dyslexia specialists;reading, writing;
SPECIAL NEEDS;learning disorders specialists;ADHD, autism spectrum, dyslexia, ;
SPECIAL NEEDS;school advocates;;
HEALTH;allergists;food allergies, pet allergies, seasonal allergies, ;
HEALTH;child psychiatrists;anxiety, ADHD, depression, neuro-psych assessment, phobias, ;
HEALTH;developmental-behavioral pediatricians;ADHD, autism spectrum, learning disorders, ;
HEALTH;fertility specialists;;
HEALTH;genetics counselors;;
HEALTH;nutritionists;asthma, anti-inflammatory diet, autoimmune disorders, breastfeeding,  diabetes, eating disorders,  feeding, fertility, food allergies/sensitivities, fussy eater/nutrition, GI (IBS\, celiac\, etc.), grocery shopping/food preparation, obesity, oncology (cancer), osteoporosis, skin conditions (psoriasis\, eczema\, etc.), sports nutrition, weight management/dieting;
HEALTH;ob-gyns;;
HEALTH;orthodontists;;
HEALTH;pediatricians;ADHD, autism spectrum, developmental delay, ;
HEALTH;pediatric dentists;;
HEALTH;sports medicine specialists;;
NEW MOM SUPPORT;doulas;childbirth, breastfeeding, postpartum ;
NEW MOM SUPPORT;lactation/infant feeding consultants;breastfeeding, fussy eater, ;
NEW MOM SUPPORT;midwives;childbirth,;
NEW MOM SUPPORT;mother's helpers;infants, toddlers;
MISC. ;kids' haircutters;;
MISC. ;kids' transport services;;
MISC. ;music teachers;bagpipes, banjo, bass, cello, clarinet, drums/percussion, flute, guitar, harmonica, harp, oboe, piano, recorder, saxophone, trumbone, trumpet, tuba, viola, violin, voice;
MISC. ;photographers;;
MISC. ;party planners/services;bar mitzvahs, bat mitzvahs, birthdays, bouncy-house rentals, entertainers/performers, party/event venues, ;
ADOPTION;adoption agencies;;
ADOPTION;adoption attorneys;;
ADOPTION;adoption facilitators;;
ADOPTION;parenting classes for adoption;;
ADOPTION;pediatricians for internationally adopted children;;
ADOPTION;therapists for adoption issues;;
CAMPS;church camps;Catholic, Episcopal, Jewish, Lutheran, Methodist, Presbyterian, ;
CAMPS;day camps;math, science, ;
CAMPS;summer camps;climbing, horseback riding, math, science, ;
HOME SERVICES;baby-proofing/home safety services;;
HOME SERVICES;diaper services;;
HOME SERVICES;home allergen inspections;;
CHILD CARE;babysitters;;
CHILD CARE;day care;;
CHILD CARE;emergency sitters;;
CHILD CARE;mother's helpers;;
CHILD CARE;nannies/au pairs;;
eof
	end
end
