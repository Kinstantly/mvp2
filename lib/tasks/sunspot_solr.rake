unless Rails.env.production?
  namespace :sunspot do
    namespace :solr do
      desc 'Start the Solr instance'
      task :start => :environment do
        case RUBY_PLATFORM
        when /w(in)?32$/, /java$/
          abort("This command is not supported on #{RUBY_PLATFORM}. " +
                "Use rake sunspot:solr:run to run Solr in the foreground.")
        end

        server.start
        puts "Successfully started Solr ..."
      end

      desc 'Run the Solr instance in the foreground'
      task :run => :environment do
        server.run
      end

      desc 'Stop the Solr instance'
      task :stop => :environment do
        case RUBY_PLATFORM
        when /w(in)?32$/, /java$/
          abort("This command is not supported on #{RUBY_PLATFORM}. " +
                "Use rake sunspot:solr:run to run Solr in the foreground.")
        end

        server.stop
        puts "Successfully stopped Solr ..."
      end

      # for backwards compatibility
      task :reindex => :"sunspot:reindex"
      
      def server
        svr = if defined?(Sunspot::Rails::Server)
          Sunspot::Rails::Server.new
        else
          Sunspot::Solr::Server.new
        end
        
        svr.solr_data_dir = File.expand_path("solr/data/#{Rails.env}")
        svr
      end
    end
  end
end
