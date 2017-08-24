# This file will contain the ESPN class and its required dependencies

# Require other dependencies here:
require 'open-uri'
require_relative 'score_parser'
 
module GameWatch
    # This class will be responsible for collecting all of the game information
    class ESPN
    
        # This function is the handler for the ESPN class
        def self.get_upcoming_games
            # Loop through the different sports
            MAJOR_SPORTS.each_key do |sport|
                download_data(sport)
            end
        end
        
        # Private methods only for ESPN class usage
        private
        
        def self.download_data( sport )
            puts "Getting data for sport: #{sport}"
            url = "http://www.espn.com/#{sport}/bottomline/scores"
            begin
                sport_raw = URI.parse( url ).read
                sport_info = ScoreParser.parse( sport, sport_raw )
            rescue OpenURI::HTTPError => each
                raise "The ESPN page #{url} cannot be accessed right now: #{e}"
            end
        end # download_data
        
        # Functions to check if connection established, etc.
    end
end