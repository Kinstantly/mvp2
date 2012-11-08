# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
window.string_present = (s) ->
	s? && s.length > 0
window.profile_display_name = (first_name, middle_name, last_name, credentials) ->
	names = []
	names.push name for name in [first_name, middle_name, last_name] when string_present name
	s = names.join(' ')
	s = s + ', ' + credentials if string_present credentials
	s
