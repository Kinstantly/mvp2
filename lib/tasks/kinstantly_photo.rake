namespace :kinstantly_photo do
	desc "Iterate through profiles and upload photo from external url to project storage"
	task :upload_from_photo_source_url => :environment do
		profile_count = 0
		profile_with_source_url = 0
		profile_source_url_failed = 0

		Profile.all.each do |profile|
			profile_count += 1
			source_url = 'nil'
			error = 'nil'
			source_url_saved = false
			if profile.photo_source_url.present? && profile.profile_photo.url == Profile::DEFAULT_PHOTO_PATH
				profile_with_source_url += 1
				source_url = profile.photo_source_url
				begin
						profile.profile_photo = URI.parse(profile.photo_source_url)
						profile.save
						source_url_saved = true
				rescue Exception => exc
						profile_source_url_failed += 1
						error =  exc.message
				end
			end
			puts("Profile #{profile.id}: source_url=> #{source_url}, saved=> #{source_url_saved}, error=> #{error}.")
		end
		puts('----------------------------')
		puts("Total profiles: #{profile_count}, profiles with source url: #{profile_with_source_url}, failed uploads: #{profile_source_url_failed}.")
	end

end
