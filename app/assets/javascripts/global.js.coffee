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

# Replacements for ECMAScript 5 methods that IE 8 does not implement.  :(

# string.trim(s) replacement.
window.trim_string = (s) ->
	s.replace /^\s+|\s+$/g, ''

# array.indexOf(value, start) replacement.
window.index_in_array = (array, value, start) ->
	start ?= 0
	return i for candidate, i in array when candidate is value and i >= start
	-1

# Place the pop-over the specified number of pixels below the top of the viewport and centered within it.
window.place_popover = (popover, pixels) ->
	popover.offset
		top: $(window).scrollTop() + pixels
		left: (($(window).width() - popover.outerWidth()) / 2) + $(window).scrollLeft()

# Do not show the autocompletion selection menu if there are no matches to the input.
# This work-around is needed because the version of the jQuery autocomplete plugin that is used by the rails3-jquery-autocomplete gem insists on showing "no existing match".
window.configure_autocomplete_form_fields = (form_field_selector, context = document) ->
	$(form_field_selector, context).on 'autocompleteresponse', (event, ui) ->
		$(this).autocomplete('close') if ui.content?[0].value.length == 0
