# Parse the html downloaded from ESPN bottomline

module GameWatch

    class ScoreParser
        
        # Handler for the ScoreParser class
        def self.parse( sport, html )
            newline_delimiter       = /#{MAJOR_SPORTS[sport]['id']}_s_left\d+=/
            first_line_delimiter    = /&#{MAJOR_SPORTS[sport]['id']}_s_delay=/
            current_or_past_game    = /^\^?(?<ranking1>\(\d+\))?\s*\^?(?<team1>.+?)\s*(?<score1>\d+)\s*\^?(?<ranking2>\(\d+\))?\s*\^?(?<team2>.+?)\s*(?<score2>\d+)\s*((?<time_left>\(((\d+:\d+\s*IN\s*(1ST|2ND|3RD|4TH|(\w*\sOT))|HALFTIME|FINAL.*)|((BOT|TOP)\s\d+(TH|ND|ST))|(END\sOF\s(1ST|2ND|4TH))|)\)))/
            future_game             = /^\^?(?<ranking1>\(\d+\))?\s*\^?(?<team1>.+?)\s+(at)+\s*\^?(?<ranking2>\(\d+\))?\s*(?<team2>.+?)\s+((?<start_time>\(\w*,?\s?\w*\s?\d*\s?\d+:\d+\s*(AM|PM)\s*ET\)))/
            
            game_data = {   'future' => {sport => []},
                            'current' => {sport => []},
                            'past' => {sport => []}
                        }
            lines = html.split( newline_delimiter )
            # Delete the first part of line because it is meaningless
            lines.delete_if{ |line| line.match( first_line_delimiter ) }
            lines.each do |raw_line|
                # Clean up the HTML to more readable text
                line = raw_line.gsub( '%20', ' ' )
                line = line.gsub( '%26', 'and' )
                #puts line
                timeframe = ""
                case line
                    when future_game
                        timeframe = "future"
                    when current_or_past_game
                        timeframe = line.include?( "(FINAL" ) ? "past" : "current"
                    else
                        raise "Was not able to parse line: #{line}"
                end
                # Pseudo variable to get info of last match group from $1-$9
                match_data = $~
                #puts match_data
                # Put data into a hash
                captures = Hash[ match_data.names.zip( match_data.captures) ]
                #puts captures.inspect
                game_data[timeframe][sport] << captures
            end
            #puts game_data.inspect
            return game_data
        end
    end
end
