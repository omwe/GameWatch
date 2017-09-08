#!/usr/bin/env ruby

# This application will check the major sports for any close games and rank games in order of importance to the user. 
# The user will get a notification if a game is of particular interest.

# Pseudocode:
# 
# Download website information from ESPN
# Parse website and put data into a hash
# Develop a ranking system for determing which game is most important
#   Rank the order of the sports
#   Rank close game
#   Rank end of game
#   Rank ranking of the team
# For now, output the upcoming game that is of most interest

# Need functions for:
#   Accessing website
#   Parsing data

require_relative 'espn'
require 'byebug'

module GameWatch
    MAJOR_SPORTS = {'mens-college-basketball' => {'id' => 'ncb', 'verbose' => 'basketball'},
                    'womens-college-basketball' => {'id' => 'ncw', 'verbose' => 'womens basketball'},
                    'college-football' => {'id' => 'ncf', 'verbose' => 'football'},
                    'nfl' => {'id' => 'nfl', 'verbose' => 'nfl'},
                    'nba' => {'id' => 'nba', 'verbose' => 'nba'},
                    'mlb' => {'id' => 'mlb', 'verbose' => 'baseball'},
                    'nhl' => {'id' => 'nhl', 'verbose' => 'hockey'}}
    #MAJOR_SPORTS = {'college-football' => {'id' => 'ncf'}}\
    #MAJOR_SPORTS = {'mlb' => {'id' => 'mlb'}}
end

# Launch the app
GameWatch::ESPN.get_upcoming_games
