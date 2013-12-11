if defined?(Footnotes) && Rails.env.development? && !defined?(RAILS_ENV) && !ENV["RAILS_ENV"]
	Footnotes.run! # first of all

	# ... other init code
end
