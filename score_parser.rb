# Parse the html downloaded from ESPN bottomline

module GameWatch

    class ScoreParser
        
        # Handler for the ScoreParser class
        def self.parse( sport, html )
            newline_delimiter       = /#{MAJOR_SPORTS[sport]['id']}_s_left\d+=/
            first_line_delimiter    = /&#{MAJOR_SPORTS[sport]['id']}_s_delay=/
            current_or_past_game    = /^\^?(?<ranking1>\(\d+\))?\s*\^?(?<team1>.+?)\s*(?<score1>\d+)\s*\^?(?<ranking2>\(\d+\))?\s*\^?(?<team2>.+?)\s*(?<score2>\d+)\s*((?<time_left>\(((\d+:\d+\s*IN\s*(1ST|2ND|(\w*\sOT))|HALFTIME|FINAL.*)|((BOT|TOP)\s\d+(TH|ND|ST))|(END\sOF\s2ND)|)\)))/
            future_game             = /^\^?(?<ranking1>\(\d+\))?\s*\^?(?<team1>.+?)\s+(at)+\s*\^?(?<ranking2>\(\d+\))?\s*(?<team2>.+?)\s+((?<start_time>\(\w*,?\s?\w*\s?\d*\s?\d+:\d+\s*(AM|PM)\s*ET\)))/
            
            games = []
            lines = html.split( newline_delimiter )
            # Delete the first part of line because it is meaningless
            lines.delete_if{ |line| line.match( first_line_delimiter ) }
            lines.each do |raw_line|
                # Clean up the HTML to more readable text
                line = raw_line.gsub( '%20', ' ' )
                line = line.gsub( '%26', 'and' )
                #puts line
                case line
                    when future_game
                    when current_or_past_game
                end
                # Pseudo variable to get info of last match group from $1-$9
                match_data = $~
                puts match_data
                # Put data into a hash
                captures = Hash[ match_data.names.zip( match_data.captures) ]
                # Add to list
                games << captures
            end
            return games
        end
    end
end