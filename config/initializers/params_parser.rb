# Work around vulnerability of some databases.
# Databases Affected:  MySQL, SQLServer and some configurations of DB2
# Not affected:        SQLite, PostgreSQL, Oracle
# https://groups.google.com/forum/?hl=en&fromgroups=#!topic/rubyonrails-security/61bkgvnSGTQ
# https://groups.google.com/forum/?hl=en&fromgroups=#!topic/rubyonrails-security/t1WFuuQyavI
# Fixed in version 3.2.11.
# ActionDispatch::ParamsParser::DEFAULT_PARSERS.delete(Mime::XML)
# ActionDispatch::ParamsParser::DEFAULT_PARSERS.delete(Mime::JSON)
