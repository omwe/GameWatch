# This file will contain the ESPN class and its required dependencies

# Require other dependencies here:
require 'open-uri'
require_relative 'score_parser'
 
module GameWatch
    # This class will be responsible for collecting all of the game information
    class ESPN
    
        # This function is the handler for the ESPN class
        def self.get_upcoming_games
            data = {'future' => {},
                    'current' => {},
                    'past' => {}
                }
            # Loop through the different sports
            MAJOR_SPORTS.each_key do |sport|
                sport_data = download_data(sport)
                ['future', 'current', 'past'].each do |key|
                    data[key].merge!( sport_data[key] )
                end
            end
            byebug
            puts data.inspect
        end
        
        # Private methods only for ESPN class usage
        private
        
        def self.download_data( sport )
            puts "Getting data for sport: #{sport}"
            url = "http://www.espn.com/#{sport}/bottomline/scores"
            begin
                sport_raw = URI.parse( url ).read
                all_sport_games = ScoreParser.parse( sport, sport_raw )
            rescue OpenURI::HTTPError => each
                raise "The ESPN page #{url} cannot be accessed right now: #{e}"
            end
            return all_sport_games
        end # download_data
        
        # Functions to check if connection established, etc.
    end
end