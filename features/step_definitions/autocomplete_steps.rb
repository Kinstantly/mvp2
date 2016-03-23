# Tip: to view the page, use: save_and_open_page

# Borrowed from the rails-jquery-autocomplete gem and tweaked.
Given /^I choose "([^"]*)" in the autocompletion list$/ do |text|
	page.execute_script %Q{ $('input[data-autocomplete]').trigger("focus") }
	page.execute_script %Q{ $('input[data-autocomplete]').trigger("keydown") }
	sleep 1
	page.execute_script %Q{ $('.ui-menu-item:contains("#{text}")').trigger("mouseenter").trigger("click"); }
end
