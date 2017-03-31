namespace :kinstantly do
	
	desc 'Convert MailChimp member delivery records for a stage-based campaign to Ruby code that will create the corresponding SubscriptionDelivery records. Example: bin/rake kinstantly:import_subscription_deliveries member_file=members_32_Months_sent_Mar_28_2017.csv source_campaign_id=8c786067ec trigger_delay_days=1184 command_file=outfile.rb'
	task import_subscription_deliveries: :environment do
		member_file = ENV['member_file']
		source_campaign_id = ENV['source_campaign_id']
		trigger_delay_days = ENV['trigger_delay_days'].try :to_i
		command_file = ENV['command_file']
		
		unless member_file.present? && File.exist?(member_file) && File.readable?(member_file)
			puts "Can not open \"#{member_file}\" for reading. Set \"member_file\"."
			return
		end
		
		unless source_campaign_id.present?
			puts "An ID for the source campaign of the subscription stage is required. Set \"source_campaign_id\"."
			return
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
