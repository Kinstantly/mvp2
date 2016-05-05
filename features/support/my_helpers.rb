# Mocks of Gibbon, a wrapper for the MailChimp API.
require File.expand_path('../../../spec/support/mailing_list_helpers', __FILE__)

# These helper modules are also loaded by the running application.
module MyHelpers
	extend ApplicationHelper
	extend UsersHelper
	extend ProfilesHelper
end
