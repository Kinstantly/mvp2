namespace :kinstantly do
	
	desc 'Convert MailChimp member delivery records for a stage-based campaign to the corresponding SubscriptionDelivery records. Reads the MailChimp member delivery records from STDIN. They should be in CSV format. Example: bin/rake kinstantly:import_subscription_deliveries source_campaign_id=8c786067ec trigger_delay_days=1184 < members_32_Months_sent_Mar_28_2017.csv'
	task import_subscription_deliveries: :environment do
		source_campaign_id = ENV['source_campaign_id']
		trigger_delay_days = ENV['trigger_delay_days'].try :to_i
		
		unless source_campaign_id.present?
			puts "An ID for the source campaign of the subscription stage is required. Set \"source_campaign_id\"."
			exit
		end
		
		unless subscription_stage = SubscriptionStage.find_by_source_campaign_id(source_campaign_id)
			puts "\n**** subscription_stage is nil! ****\n\n"
			exit
		end
		
		unless list_id = subscription_stage.list_id
			puts "\n**** list_id is nil! ****\n\n"
			exit
		end
		
		trigger_delay_days ||= subscription_stage.trigger_delay_days
		unless trigger_delay_days
			puts "\n**** trigger_delay_days is nil! ****\n\n"
			exit
		end
		
		if subscription_stage.trigger_delay_days && subscription_stage.trigger_delay_days != trigger_delay_days
			puts "\n**** trigger_delay_days is different from subscription_stage.trigger_delay_days! ****"
			puts "Continuing...\n\n"
		end
		
		delivery_time = trigger_delay_days > 0 ? 6 : 9 # Pregnancy stages were sent at 9am.
		
		puts "subscription_stage:\t#{subscription_stage.inspect}\n\n"
		puts "source_campaign_id:\t#{source_campaign_id}"
		puts "list_id:\t#{list_id}"
		puts "trigger_delay_days:\t#{trigger_delay_days}"
		puts "delivery_time:\t#{delivery_time}"
		
		# Read CSV file from standard input.
		count = 0
		while line = STDIN.gets
			next if line.include? 'Email Address' # header
			
			fields = line.split ','
			email, birth1 = fields[0], fields[3]
			
			schedule_time = if birth1.present?
				Time.zone.parse(birth1) + trigger_delay_days.days + delivery_time.hours
			else
				nil
			end
			
			subscription = Subscription.find_by_lower_email_and_list_id email, list_id
			
			subscription_delivery = SubscriptionDelivery.find_or_create_by email: email, subscription: subscription, subscription_stage: subscription_stage, source_campaign_id: source_campaign_id, schedule_time: schedule_time
			subscription_delivery.update created_at: schedule_time if schedule_time
			
			puts "\nemail: #{email}\tbirth1: #{birth1}"
			puts subscription_delivery.inspect
			
			count += 1
		end
		
		# Once we have created the delivery records, it's safe to enable sending.
		if subscription_stage.trigger_delay_days
			puts "\n**** subscription_stage.trigger_delay_days is already set. Not updating. ****"
		elsif count == 0
			puts "\n**** No delivery records! Not updating subscription_stage. ****"
		else
			subscription_stage.update trigger_delay_days: trigger_delay_days
		end
		
		puts "\ndelivery records:\t#{count}"
		
		puts subscription_stage.inspect
	end
	
	desc 'Convert MailChimp member delivery records for a stage-based campaign to Ruby code that will create the corresponding SubscriptionDelivery records. Example: bin/rake kinstantly:commands_to_import_subscription_deliveries member_file=members_32_Months_sent_Mar_28_2017.csv source_campaign_id=8c786067ec trigger_delay_days=1184 command_file=outfile.rb'
	task commands_to_import_subscription_deliveries: :environment do
		member_file = ENV['member_file']
		source_campaign_id = ENV['source_campaign_id']
		trigger_delay_days = ENV['trigger_delay_days'].try :to_i
		command_file = ENV['command_file']
		
		unless member_file.present? && File.exist?(member_file) && File.readable?(member_file)
			puts "Can not open \"#{member_file}\" for reading. Set \"member_file\"."
			exit
		end
		
		unless source_campaign_id.present?
			puts "An ID for the source campaign of the subscription stage is required. Set \"source_campaign_id\"."
			exit
		end
		
		commands = []
		commands << "source_campaign_id = '#{source_campaign_id}'"
		commands << "subscription_stage = SubscriptionStage.find_by_source_campaign_id source_campaign_id"
		commands << 'list_id = subscription_stage.try :list_id'
		commands << 'puts "\n**** subscription_stage is nil! ****\n\n" unless subscription_stage'
		commands << '#### Run the above before proceeding.'
		commands << "\n"
		
		commands << "trigger_delay_days = #{trigger_delay_days} || subscription_stage.trigger_delay_days"
		commands << 'puts "\n**** trigger_delay_days is nil! ****\n\n" unless trigger_delay_days'
		commands << 'puts "\n**** trigger_delay_days is different from subscription_stage.trigger_delay_days! ****\n\n" if subscription_stage.trigger_delay_days && trigger_delay_days && subscription_stage.trigger_delay_days != trigger_delay_days'
		commands << '#### Run the above before proceeding.'
		commands << "\n"
		
		commands << 'delivery_time = trigger_delay_days > 0 ? 6 : 9' # Pregnancy stages were sent at 9am.
		commands << "\n"
		
		File.open(member_file, 'r') do |file|
			while line = file.gets
				next if line.include? 'Email Address' # header
				
				fields = line.split ','
				email, birth1 = fields[0], fields[3]
				
				commands << if birth1.present?
					"schedule_time = Time.zone.parse('#{birth1}') + trigger_delay_days.days + delivery_time.hours"
				else
					'schedule_time = nil'
				end
				
				commands << "subscription = Subscription.find_by_lower_email_and_list_id '#{email}', list_id"
				
				commands << "delivery = SubscriptionDelivery.find_or_create_by email: '#{email}', subscription: subscription, subscription_stage: subscription_stage, source_campaign_id: source_campaign_id, schedule_time: schedule_time"
				commands << "delivery.update created_at: schedule_time if schedule_time"
			end
			
			commands << "\n"
			# Automatically closes the file at the end of block.
		end
		
		# Once we have created the delivery records with the above commands, it's safe to enable sending.
		commands << "subscription_stage.update trigger_delay_days: trigger_delay_days unless subscription_stage.trigger_delay_days"
		
		# Output the commands.
		if command_file.present?
			File.open(command_file, 'w') do |file|
				commands.each do |line|
					file.puts line
				end
			end
		else
			# STDOUT
			commands.each do |line|
				puts line
			end
		end
	end
	
end
