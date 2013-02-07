# Work around vulnerability of some databases.
# Databases Affected:  MySQL, SQLServer and some configurations of DB2
# Not affected:        SQLite, PostgreSQL, Oracle
# https://groups.google.com/forum/?hl=en&fromgroups=#!topic/rubyonrails-security/61bkgvnSGTQ
ActionDispatch::ParamsParser::DEFAULT_PARSERS.delete(Mime::XML)
ActionDispatch::ParamsParser::DEFAULT_PARSERS.delete(Mime::JSON)
