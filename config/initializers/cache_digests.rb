if defined?(CacheDigests::DependencyTracker)
	# Track rendering dependencies in HAML templates.
	CacheDigests::DependencyTracker.register_tracker :haml, CacheDigests::DependencyTracker::ERBTracker
elsif defined?(ActionView::DependencyTracker)
	# This will apply when we are running Rails 4, which includes 'action_view/dependency_tracker'.
	# require 'action_view/dependency_tracker'
	ActionView::DependencyTracker.register_tracker :haml, ActionView::DependencyTracker::ERBTracker
	ActionView::Base.cache_template_loading = false if ::Rails.env.development?
end
