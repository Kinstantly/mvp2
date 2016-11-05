# Spring configuration.
# This file is loaded after bundler.
# See https://github.com/rails/spring.
# Note that ~/.spring.rb is loaded before bundler.

# Spring will automatically detect file changes to any file loaded when the server boots.
# Changes will cause the affected environments to be restarted.
# If there are additional files or directories which should trigger an application restart,
# you can specify them with Spring.watch.

Spring.watch 'config/sunspot.yml'
