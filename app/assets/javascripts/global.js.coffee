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

# Sniff UserAgent and detect mobile platform if possible
window.user_agent_info = ->
		ua = navigator.userAgent.toLowerCase()
		info =
			user_agent: ua
			iphone: ua.match(/(iphone|ipod|ipad)/i)
			blackberry: ua.match(/blackberry/i)
			android: ua.match(/android/i)
		info

# Link the given address elements to an external map app or URL.
window.link_addresses_to_map = (addresses) ->
	for address in addresses
		address = $(address)
		address.addClass('linked_address')
		lat = address.attr('data-latitude')
		lng = address.attr('data-longitude')
		if lat && lng
			user_agent_info = window.user_agent_info()
			escaped_address = escape(address.text())
			address.attr target: '_blank'
			if(user_agent_info.iphone)
				address.attr href: 'maps:q=' + escaped_address + '@' + lat + ',' + lng
			else if(user_agent_info.android)
				address.attr href: 'geo:' + lat + ',' + lng + '?q=' + escaped_address
			else
				address.attr href: 'http://maps.google.com/maps?q=' + escaped_address + '&ll=' + lat + ',' + lng

# Name-space my global variables, e.g., my_vars.a_val, my_vars.t.some_text, my_vars.f.a_function
window.my_vars= t: {}, f:{}
my_vars = window.my_vars

# Place the formlet the specified number of pixels below the top of the viewport.
my_vars.f.place_formlet = (formlet) ->
	place_popover $('.popover', formlet), 20

# Close any open formlets.
my_vars.f.close_formlets = (e) ->
	$('.formlet.active').removeClass 'active'
	$(document).off 'click', my_vars.f.outer_close_formlets
	$('.open-formlet-popover').on 'click', my_vars.f.open_formlet
	$('.open-photo-popover').on 'click', my_vars.profile_photo_module.open_popover if my_vars.profile_photo_module
	false # No bubble up.

# Close open formlets if clicked outside open formlet.
my_vars.f.outer_close_formlets = (e) ->
	clicked = $(e.target)
	if clicked.closest('.popover', '.formlet.active').length == 0 && clicked.closest('.ui-autocomplete').length == 0
		my_vars.f.close_formlets e

# Open the formlet unless already activated or we clicked on a 'dont_popover' element.
my_vars.f.open_formlet = (e) ->
	unless $(this).hasClass('active') or $(e.target).hasClass('dont_popover')
		$('.formlet.active').removeClass 'active' # Close any active formlet.
		$(this).addClass 'active'
		my_vars.f.place_formlet this
		$('.open-formlet-popover').off 'click', my_vars.f.open_formlet
		$('.open-photo-popover').off 'click', my_vars.profile_photo_module.open_popover if my_vars.profile_photo_module
		$(document).on 'click', my_vars.f.outer_close_formlets
		false

# Final touches to a newly created or updated formlet element.
my_vars.f.configure_formlet = (formlet) ->
	# Add close button to top of pop-over if not already added.
	if $('.close-popover-button', formlet).length == 0
		$('.edit.popover', formlet).prepend '<div class="cancel close-popover-button"></div>'
	# Cancel buttons should close the formlet.
	$('.cancel', formlet).on 'click', my_vars.f.close_formlets
	# Autocompletion configuration that must be done or redone.
	configure_autocomplete_form_fields '.autocomplete-form-field', formlet
