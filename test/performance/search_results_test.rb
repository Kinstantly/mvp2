require 'performance_test_helper'
# require 'test_helper'
# require 'rails/performance_test_help'

class SearchResultsTest < ActionDispatch::PerformanceTest
  # Refer to the documentation for all available options
  # self.profile_options = { :runs => 5, :metrics => [:wall_time, :memory]
  #                          :output => 'tmp/performance', :formats => [:flat] }

  def test_by_service_id
    get '/search_providers/service/47'
  end
end
