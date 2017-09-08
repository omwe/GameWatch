module Applications

    require 'open-uri'

    class GameWatch < Application
        # Define the major sports avaliable for use by this app
        MAJOR_SPORTS = {'mens-college-basketball' => {'id' => 'ncb', 'verbose' => ['basketball', 'college basketball']},
                    'womens-college-basketball' => {'id' => 'ncw', 'verbose' => ['womens basketball']},
                    'college-football' => {'id' => 'ncf', 'verbose' => ['football', 'college football']},
                    'nfl' => {'id' => 'nfl', 'verbose' => ['nfl', 'professional football']},
                    'nba' => {'id' => 'nba', 'verbose' => ['nba', 'professional basketball']},
                    'mlb' => {'id' => 'mlb', 'verbose' => ['baseball', 'mlb', 'major league baseball']},
                    'nhl' => {'id' => 'nhl', 'verbose' => ['hockey']}}
    
    
        # get_response
        # Inputs: raw request
        # Outputs: response
        def get_response( request_in )
            # Nothing to do with the request for now,
            #   # just check the sensor table
            @request = convert_json_to_hash( request_in )
            type = determine_type
            case type
            when "LaunchRequest"
                response = respond_to_launch
            when "IntentRequest"
                response = respond_to_intent
            end
            return [GOOD_RESPONSE_CODE, {'Content-Type' => 'application/json;charset=UTF-8'}, [convert_hash_to_json( response )]]
        end # get_response
        
        private
        
        # Respond to a Skill Launch Request
        def respond_to_launch
            build_response( "Hello world" )
        end # respond_to_launch
        
        # Respond to a Skill Intent Request
        def respond_to_intent
            case @request["request"]["intent"]["name"]
                when "FutureGame"
                    custom_games( 'future', @request["request"]["intent"]["slots"]["Sport"]["value"] )
            end
        end # respond_to_intent

        def determine_type
            @request["request"]["type"]
        end # determine_type

        def build_response( spoken_text, sessionAttributes={}, end_session=true )
            version = "1.0"
            response = {
                :version => version,
                :sessionAttributes => sessionAttributes,
                :response => {
                    :outputSpeech => {
                        :type => "PlainText",
                        :text => spoken_text
                    },
                    :shouldEndSession => end_session
                }
            }
        end # build_response
        
        def is_valid_sport?( sport )
            if MAJOR_SPORTS.map{ |key, hash| hash['verbose'] }.flatten.include?( sport.downcase )
                # find returns an array with the first element as the key of the first match
                return MAJOR_SPORTS.find{ |key, hash| hash['verbose'].include?( sport.downcase ) }.first
            else
                return false
            end
        end
        
        def custom_games( time, sport )
            # check if the sport is recognized
            if sport_id = is_valid_sport?( sport )
                games = download_data( sport_id )[time][sport_id]
                build_response( "#{get_valuable_games( games )}" )
                #puts "#{get_valuable_games( games )}"
            else
                build_response( "The sport #{sport} is not supported by Game Watch" )
            end
        end # custom_games
        
        def download_data( sport )
            url = "http://www.espn.com/#{sport}/bottomline/scores"
            begin
                sport_raw = URI.parse( url ).read
                all_sport_games = parse_html( sport, sport_raw )
            rescue OpenURI::HTTPError => each
                raise "The ESPN page #{url} cannot be accessed right now: #{e}"
            end
            return all_sport_games
        end # download_data
        
        def parse_html( sport, html )
            newline_delimiter       = /#{MAJOR_SPORTS[sport]['id']}_s_left\d+=/
            first_line_delimiter    = /&#{MAJOR_SPORTS[sport]['id']}_s_delay=/
            current_or_past_game    = /^\^?(?<ranking1>\(\d+\))?\s*\^?(?<team1>.+?)\s*(?<score1>\d+)\s*\^?(?<ranking2>\(\d+\))?\s*\^?(?<team2>.+?)\s*(?<score2>\d+)\s*((?<time_left>\(((\d+:\d+\s*IN\s*(1ST|2ND|3RD|4TH|(\w*\sOT))|CANCELLED|HALFTIME|FINAL.*)|((BOT|TOP)\s\d+(TH|ND|ST))|(END\sOF\s(1ST|2ND|4TH))|)\)))/
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
        end # parse_html
        
        def get_valuable_games( game_array )
            # If both teams are ranked for now
            # Narrow down the list of games, then make verbal
            ranked_games = game_array.select{ |game| !game['ranking1'].nil? && !game['ranking2'].nil? }
            game_to_text( ranked_games )
        end # get_valuable_games
        
        def game_to_text( game_array )
            text = ""
            game_array.each do |game|
                text += "Number #{game['ranking1']}" if !game['ranking1'].nil?
                text += " #{game['team1']}"
                text += " is playing"
                text += " Number #{game['ranking2']}" if !game['ranking2'].nil?
                text += " #{game['team2']}"
                text += " on"
                text += " #{get_time(game['start_time'])}"
            end
            # Delete any parentheses, as these pause Alexa speech
            return text.tr("()","")
        end
        
        def get_time( text )
            time_regex = /((?<weekday>\w+),\s+(?<month>\w+)\s+(?<day>\d+)\s+(?<hour>\d+):(?<minute>\d+)\s+(?<part>\w+)\s+(?<timezone>\w+))/
            time_details = text.match( time_regex )
            case time_details['weekday']
                when "MON"
                    weekday = "Monday"
                when "TUE"
                    weekday = "Tuesday"
                when "WED"
                    weekday = "Wednesday"
                when "THU"
                    weekday = "Thursday"
                when "FRI"
                    weekday = "Friday"
                when "SAT"
                    weekday = "Saturday"
                when "SUN"
                    weekday = "Sunday"
            end
            case time_details['month']
                when "JAN"
                    month = "January"
                when "FEB"
                    month = "February"
                when "MAR"
                    month = "March"
                when "APR"
                    month = "April"
                when "MAY"
                    month = "May"
                when "JUN"
                    month = "June"
                when "JUL"
                    month = "July"
                when "AUG"
                    month = "August"
                when "SEP"
                    month = "September"
                when "OCT"
                    month = "October"
                when "NOV"
                    month = "November"
                when "DEC"
                    month = "December"
            end
            minute = time_details['minute'] == "00" ? "" : " #{time_details['minute']}"
            return " #{weekday} #{month} #{time_details['day']} at #{time_details['hour']}#{minute} #{time_details['part']}. "
        end # get_time
        
    end # GameWatch
end
